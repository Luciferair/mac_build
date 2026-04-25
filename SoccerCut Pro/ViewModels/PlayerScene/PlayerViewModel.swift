//
//  PlayerViewModel.swift
//  SoccerCut Pro
//
//  Created by Naoki Tanaka on 2023/05/28.
//

import AVFoundation
import Cocoa

class PlayerViewModel: ObservableObject {
    private(set) var side: ScreenSides!
    private(set) var playersViewModel: PlayersViewModel!
    private(set) var playerModel: PlayerModel!
    var player: AVPlayer? { playerModel.player }
    @Published private(set) var isMuted: Bool = false
    @Published var muteSoundImgName: String = "speaker.wave.2.fill"
    @Published var volume: Double = 1
    @Published private(set) var isPlaying: Bool = false
    @Published var playPauseImgName: String = "play.fill"
    @Published private(set) var rewindLabelValue: String = ""
    @Published private(set) var skipLabelValue: String = ""
    @Published private(set) var durationSecs: Double = 0
    @Published private(set) var currentSecs: Double = 0
    @Published private(set) var durationLabel: String = "00:00:00"
    @Published private(set) var currentTimeLabel: String = "00:00:00"
    @Published private(set) var isShownTrimmingMarker: Bool = false
    @Published private(set) var trimmingStartMarkerOffsetX: Double = 0
    @Published private(set) var trimmingEndMarkerOffsetX: Double = 0
    @Published private(set) var showControls: Bool = false
    
    var viewFrame: CGRect = .zero
    var ctrlsFrame: CGRect = .zero
    var isExecutingTrimming: Bool { playerModel.isExecutingTrimming }
    private let ctrlsAppearingSecs: Double = 2
    private var remainingCtrlsAppearingSecs: Double = 0
    var fileURL: URL? { playerModel.fileURL }
    var trimmingErrorMsg: String? { playerModel.trimmingErrorMsg }
    var trimmingStatus: AVAssetExportSession.Status? { playerModel.trimmingStatus }

    // padding合計+シークバーのラベル+つまみの半分の大きさ = 左端からつまみの中央までの距離
    private let thumbCenterX = (10.0 + 10.0) + 84.0 + 10.0
    
    func initialize(side: ScreenSides, playersViewModel: PlayersViewModel, playerModel: PlayerModel) {
        self.side = side
        self.playersViewModel = playersViewModel
        self.playerModel = playerModel
    }
        
    func onSelectFile(url: URL) {
        playerModel.openFile(url: url)
        startShowingControls()
        
        // マウス移動検知
        NSEvent.addLocalMonitorForEvents(matching: .mouseMoved) { (event) -> NSEvent in
            let mousePos = event.locationInCGWindow
            
            // SyncModeの場合は親（PlayersViewModel）に任せる
            if self.playersViewModel.isSyncMode { return event }
            // マウスがウィンドウ外/PlayerView外ならControls非表示
            if event.window == nil || !self.viewFrame.contains(mousePos) {
                self.hideControls()
                return event
            }
            // マウスがControls内にあるか判定 -> SwiftUIのonHoverを使うと画面下端が必ずtrueになってしまうのでここで判定
            if self.ctrlsFrame.contains(mousePos) {
                self.startShowingControls(isNoTimeLimit: true)
                return event
            }
            // ここまできたらマウスがPlayersView内・Controls外
            self.startShowingControls()
            return event
        }
        
        // マウスクリック検知
        NSEvent.addLocalMonitorForEvents(matching: .leftMouseDown) { (event) -> NSEvent in
            let mousePos = event.locationInCGWindow
                
            // SyncModeの場合は親（PlayersViewModel）に任せる
            if self.playersViewModel.isSyncMode { return event }
            // マウスがウィンドウ外の場合は何もしない
            if event.window == nil { return event }
            // マウスがPlayerView上の場合最終クリック時間を更新
            if self.viewFrame.contains(mousePos) { self.playerModel.updateLastlyActivatedViewTime() }
            // マウスがControls上の場合は終了
            if self.ctrlsFrame.contains(mousePos) { return event }
            // Controlsを非表示にする
            self.hideControls()
            return event
        }
        
        // rate変更検知
        NotificationCenter.default.addObserver(self, selector: #selector(self.onChangeRate),
                                               name: AVPlayer.rateDidChangeNotification,
                                               object: playerModel.player!)
        
        // 定期実行
        let timeInterval = 0.2
        Timer.scheduledTimer(withTimeInterval: timeInterval, repeats: true, block: { (timer) in
            guard
                let player = self.playerModel.player,
                let duration = self.playerModel.duration,
                let currentTime = self.playerModel.currentTime
            else { return }
            if duration.seconds.isNaN { return }
            
            // 音量情報の更新
            self.isMuted = player.isMuted
            self.volume = Double(player.volume)
            self.muteSoundImgName = player.isMuted ? "speaker.slash.fill" : "speaker.wave.2.fill"
            
            // 再生時間の更新
            self.durationSecs = duration.seconds
            self.currentSecs = currentTime.seconds

            // 再生時間ラベルの更新
            self.durationLabel = Int(self.durationSecs).formatToHHMMSS()!
            self.currentTimeLabel = Int(self.currentSecs).formatToHHMMSS()!
            
            if self.isShownTrimmingMarker {
                self.trimmingEndMarkerOffsetX
                = self.viewFrame.size.width / 2.0 // 基準を中央から左端に変える
                    - self.thumbCenterX // つまみの左右中央の位置に合うよう右に移動
                    - (self.viewFrame.size.width - self.thumbCenterX * 2) * currentTime.seconds / duration.seconds // シークバーがminValueからどれくらい移動しているかを計算して移動距離に位置を合わせる
            }
            
            // Controlの非表示タイミングを検知&非表示
            if self.remainingCtrlsAppearingSecs == 0 { return }
            // 早送り・巻戻し・トリミングマーカー表示中はControlを非表示にしない
            if self.playerModel.playingState.isSkip || self.playerModel.playingState.isRewind || self.isShownTrimmingMarker { return }
            self.remainingCtrlsAppearingSecs -= timeInterval
            if self.remainingCtrlsAppearingSecs < 0 {
                self.hideControls()
                NSCursor.setHiddenUntilMouseMoves(true)
            }
        })
        
        playersViewModel.onSelectFile()
    }
    
    @objc func onChangeRate() {
        isPlaying = playerModel.isPlaying
        playPauseImgName = isPlaying ? "pause.fill" : "play.fill"
        rewindLabelValue = playerModel.playingState.rewindLabel
        skipLabelValue = playerModel.playingState.skipLabel
    }
    
    func startShowingControls(isNoTimeLimit: Bool = false) {
        showControls = true
        remainingCtrlsAppearingSecs = isNoTimeLimit ? 0 : ctrlsAppearingSecs
    }
    
    func hideControls() {
        showControls = false
        remainingCtrlsAppearingSecs = 0
    }
    
    func updateLastlyActivatedViewTime() {
        playerModel.updateLastlyActivatedViewTime()
    }
    
    func onClickMuteSoundBtn() { playerModel.toggleIsMuted() }
    func onSlideVolumeSlider(newValue: Double) { playerModel.changeVolume(Float(newValue)) }
    func onClickRewindBtn() { playerModel.rewind() }
    func onClickPlayPauseBtn() { playerModel.togglePlayPause() }
    func onClickSkipBtn() { playerModel.skip() }
    func onSlideSeekBar(newValue: Double) { playerModel.seekTo(newValue) }
    
    func onShowTrimmingMarker() {
        guard
            let duration = playerModel.duration,
            let currentTime = playerModel.currentTime
        else { return }
        
        playerModel.setTrimmingStart()
        
        isShownTrimmingMarker = true
        trimmingStartMarkerOffsetX = viewFrame.size.width / 2.0 // 基準を中央から左端に変える
        - thumbCenterX // つまみの左右中央の位置に合うよう右に移動
        - (viewFrame.size.width - thumbCenterX * 2) * currentTime.seconds / duration.seconds // シークバーがminValueからどれくらい移動しているかを計算して移動距離に位置を合わせる
        
        trimmingEndMarkerOffsetX = trimmingStartMarkerOffsetX
    }
    
    func onSelectPathForSavingTrimmedFile(exportUrl: URL) {
        playerModel.pause()
        Task.detached(priority: .userInitiated) { [weak self] in
            guard let self = self else { return }
            await self.playerModel.trim(exportUrl: exportUrl)
        }
    }
    
    func onClickOKInProcessingView() {
        isShownTrimmingMarker = false
        trimmingStartMarkerOffsetX = 0
        trimmingEndMarkerOffsetX = 0
        playerModel.clearTrimmingErrorMsgAndStatus()
    }
    
    func onClickPencilButton() {
        // サブスクの有無確認
        if !ValidTransactions.instance.isEligibleFor(appMode: .penTool) {
            // サブスクリプションライセンスが無いので選択画面を表示
            Products.instance.selection()
            return
        }
        
        let storyboard = NSStoryboard(name: "Main", bundle: nil)
        if let windowController = storyboard.instantiateController(withIdentifier: "PenToolWindowID") as? NSWindowController { windowController.showWindow(self)
            PenToolViewController.fileUrl = self.fileURL
        }
    }
}
