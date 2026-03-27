//
//  PlayersViewModel.swift
//  SoccerCut Pro
//
//  Created by Naoki Tanaka on 2023/06/01.
//

import Cocoa

class PlayersViewModel: ObservableObject {
    private(set) var playersModel: PlayersModel!
    private(set) var showingScreenSides: ScreenSides = .left
    private(set) var both: [PlayerViewModel] = []
    var left: PlayerViewModel { both.first(where: { $0.side == .left })! }
    var right: PlayerViewModel { both.first(where: { $0.side == .right })! }
    
    @Published private(set) var bothPlayersHaveLoadedFile: Bool = false
    @Published var audioSideImgIsFilppedX: Bool = false
    @Published var syncModeImgName: String = "circle.slash" // "arrow.triangle.2.circlepath"
    @Published var fullScreenModeImgName: String = "arrow.down.right.and.arrow.up.left" // "arrow.up.left.and.arrow.down.right"
    @Published private(set) var isSyncMode: Bool = false
    @Published private(set) var isFullScreen: Bool = false
    @Published private(set) var showDualSwitches: Bool = false
    
    var viewFrame: CGRect = .zero
    var switchesFrameInPlayersView: CGRect = .zero
    private let dualSwitchesAppearingSecs: Double = 2
    private var remainingDualSwitchesAppearingSecs: Double = 0
    
    var nextEmptySide: ScreenSides? { playersModel.nextEmptySide }
    var trimmingTargetSide: ScreenSides? { playersModel.lastlyActivatedTarget?.side }
    
    func initialize(selfs: [PlayerViewModel], playersModel: PlayersModel) {
        both = selfs
        self.playersModel = playersModel
    }
    
    func onSelectFile() {
        // 2つ目のファイル読込の場合は検知処理を開始しない（既に開始済み）
        if nextEmptySide == nil { return }
        
        // マウス移動検知
        NSEvent.addLocalMonitorForEvents(matching: .mouseMoved) { (event) -> NSEvent in
            let mousePos = event.locationInCGWindow

            // マウスがウィンドウ外/PlayersView外ならSwitches・Controls非表示
            if event.window == nil || !self.viewFrame.contains(mousePos) {
                self.hideDualSwitches()
                self.hide2CtrlsIfSyncMode()
                return event
            }
            // マウスがSwitches内にあるか判定 -> SwiftUIのonHoverを使うと画面下端が必ずtrueになってしまうのでここで判定
            let switchesFrame = self.switchesFrameInPlayersView + CGRect(origin: self.viewFrame.origin, size: .zero)
            if switchesFrame.contains(mousePos) {
                self.startShowingDualSwitches(isNoTimeLimit: true)
                self.startShowing2CtrlsIfSyncMode()
                return event
            }
            // マウスがいずれかのControls内にあるか判定
            if self.both.first(where: { $0.ctrlsFrame.contains(mousePos) }) != nil {
                self.startShowingDualSwitches()
                self.startShowing2CtrlsIfSyncMode(isNoTimeLimit: true)
                return event
            }
            // ここまできたらマウスがPlayersView内・Switches/Controls外
            self.startShowingDualSwitches()
            self.startShowing2CtrlsIfSyncMode()
            return event
        }
        
        // マウスクリック検知
        NSEvent.addLocalMonitorForEvents(matching: .leftMouseDown) { (event) -> NSEvent in
            let mousePos = event.locationInCGWindow

            // マウスがウィンドウ外の場合は何もしない
            if event.window == nil { return event }
            // マウスがSwitches上の場合は何もしない
            let switchesFrame = self.switchesFrameInPlayersView + CGRect(origin: self.viewFrame.origin, size: .zero)
            if switchesFrame.contains(mousePos) { return event }
            if self.playersModel.isSyncMode {
                // マウスがPlayerView上の場合最終クリック時間を更新
                self.both.forEach({
                    if $0.viewFrame.contains(mousePos) { $0.playerModel.updateLastlyActivatedViewTime() }
                })
            }
            // マウスがControls上の場合は終了
            if self.both.first(where: { $0.ctrlsFrame.contains(mousePos) }) != nil { return event }
            // SwitchesとControlsを非表示にする
            self.hideDualSwitches()
            self.hide2CtrlsIfSyncMode()
            
            return event
        }
        
        // 定期実行
        let timeInterval = 0.2
        Timer.scheduledTimer(withTimeInterval: timeInterval, repeats: true, block: { (timer) in
            // スクリーンの状態と同期
            self.isFullScreen = NSApplication.shared.keyWindow?.isFullScreen ?? false
            // PlayersModelの状態と同期
            self.bothPlayersHaveLoadedFile = self.nextEmptySide == nil
            self.audioSideImgIsFilppedX = self.playersModel.audioSide == .right
            self.isSyncMode = self.playersModel.isSyncMode
            self.syncModeImgName = self.isSyncMode ? "arrow.triangle.2.circlepath" : "circle.slash"
            self.fullScreenModeImgName = self.isFullScreen ? "arrow.down.right.and.arrow.up.left"
                                                           : "arrow.up.left.and.arrow.down.right"
            
            if self.remainingDualSwitchesAppearingSecs == 0 { return }
            self.remainingDualSwitchesAppearingSecs -= timeInterval
            if self.remainingDualSwitchesAppearingSecs < 0 {
                self.hideDualSwitches()
            }
        })
    }
    
    private func startShowingDualSwitches(isNoTimeLimit: Bool = false) {
        self.showDualSwitches = true
        self.remainingDualSwitchesAppearingSecs = isNoTimeLimit ? 0 : self.dualSwitchesAppearingSecs
    }
    
    private func hideDualSwitches() {
        self.showDualSwitches = false
        self.remainingDualSwitchesAppearingSecs = 0
    }
    
    private func startShowing2CtrlsIfSyncMode(isNoTimeLimit: Bool = false) {
        if !isSyncMode { return }
        both.forEach({ $0.startShowingControls(isNoTimeLimit: isNoTimeLimit) })
    }
    
    private func startShowingLastlyActivatedCtrlsIfNotSyncMode(isNoTimeLimit: Bool = false) {
        if isSyncMode { return }
        guard let currentSide = playersModel.lastlyActivatedTarget?.side else { return }
        currentSide == .left ? left.startShowingControls() : right.startShowingControls()
    }
    
    private func hide2CtrlsIfSyncMode() {
        if !isSyncMode { return }
        both.forEach({ $0.hideControls() })
    }
    
    func onClickTogglePlayPauseMenu() { playersModel.togglePlayPause() }
    // skip/rewindはキーを押し続けず1回押したら放置なのでPlayerViewModelの方でCtrlsの表示・非表示を管理
    func onClickSkipMenu(rate: Float? = nil) { playersModel.skip(rate: rate) }
    func onClickRewindMenu(rate: Float? = nil) { playersModel.rewind(rate: rate) }
    // seek/stepはキーを押し続けている場合Ctrlsを表示
    func onClickSeek5SecsForwardMenu() {
        playersModel.seek5SecsForward()
        isSyncMode ? startShowing2CtrlsIfSyncMode() : startShowingLastlyActivatedCtrlsIfNotSyncMode()
    }
    func onClickSeek5SecsBackwardMenu() {
        playersModel.seek5SecsBackward()
        isSyncMode ? startShowing2CtrlsIfSyncMode() : startShowingLastlyActivatedCtrlsIfNotSyncMode()
    }
    func onClickStepForwardMenu() {
        playersModel.stepForward()
        isSyncMode ? startShowing2CtrlsIfSyncMode() : startShowingLastlyActivatedCtrlsIfNotSyncMode()
    }
    func onClickStepBackwardMenu() {
        playersModel.stepBackward()
        isSyncMode ? startShowing2CtrlsIfSyncMode() : startShowingLastlyActivatedCtrlsIfNotSyncMode()
    }
    
    func onClickSwitchAudioBtn() { playersModel.switchAudio() }
    func onClickSwitchSyncModeBtn() { playersModel.switchSyncMode() }
    func onClickSwitchFullScreenModeBtn() { NSApplication.shared.keyWindow?.toggleFullScreen(self) }
    
    func onClickOKInProcessingView() {
        both.forEach({ $0.onClickOKInProcessingView() })
    }
    
    func onSwitchScreen(to newScreenMode: ScreenSides) {
        showingScreenSides = newScreenMode
    }
}
