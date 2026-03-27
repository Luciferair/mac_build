//
//  PlayerModel.swift
//  SoccerCut Pro
//
//  Created by Naoki Tanaka on 2023/06/07.
//

import AVFoundation
import Cocoa
import SwiftUI

class PlayerModel {
    let side: ScreenSides
    private let playersModel: PlayersModel
    private(set) var fileURL: URL? = nil
    var player: AVPlayer? = nil
    var isPlaying: Bool { player != nil && playingState != .pause && player?.error == nil }
    var playingState: PlayingState {
        guard let player = self.player else { return .pause }
        return PlayingState(rawValue: player.rate) ?? .pause
    }
    var duration: CMTime? { player?.currentItem?.duration }
    var currentTime: CMTime? { player?.currentTime() }
    var isMuted: Bool { player == nil || player!.isMuted }
    var volume: Float { player != nil ? player!.volume : 0 }
    private(set) var trimmingStartSecs: Double? = nil
    private(set) var trimmingEndSecs: Double? = nil   // Bug②: capture end time before save dialog
    private(set) var isExecutingTrimming: Bool = false
    private(set) var trimmingErrorMsg: String? = nil
    private(set) var trimmingStatus: AVAssetExportSession.Status? = nil
    private(set) var lastlyActivatedViewTime: Date = Date()
    private var playerItem: AVPlayerItem? = nil
    
    init(side: ScreenSides, playersModel: PlayersModel) {
        self.side = side
        self.playersModel = playersModel
    }
    
    func updateLastlyActivatedViewTime() { lastlyActivatedViewTime = Date() }
    
    func openFile(url: URL) {
        self.fileURL = url
        self.player = AVPlayer(url: url)
        self.playerItem = self.player?.currentItem
        self.player?.preventsDisplaySleepDuringVideoPlayback = true
        self.playersModel.addObserversIfBothPlayersHaveGetReady()
    }
    
    func restoreCurrentPlayerItem() {
        player?.replaceCurrentItem(with: playerItem)
    }
    
    func toggleIsMuted() { player?.isMuted.toggle() }
    func setIsMuted(_ isMuted: Bool) { player?.isMuted = isMuted }
    func changeVolume(_ volume: Float) { player?.volume = volume }
    
    // rate系は親(PlayersModel)側でどちらのsideのrateが変わったか判別できるので子側では何も考えない
    func play() { player?.play() }
    func pause() { player?.pause() }
    func togglePlayPause() { isPlaying ? pause() : play() }
    func skip(rate: Float? = nil) { player?.rate = rate ?? playingState.rateIfSkip }
    func rewind(rate: Float? = nil) { player?.rate = rate ?? playingState.rateIfRewind }
    
    // stepが関係する処理は手動で同期
    func step(_ stepWidth: Int, isSyncOpponent: Bool = false) {
        player?.currentItem?.step(byCount: stepWidth)
        if !isSyncOpponent { playersModel.syncStepIfSyncMode(opponent: side.theOtherSide!, stepWidth: stepWidth) }
    }
    
    // seekが関係する処理は手動で同期
    func seekTo(_ seconds: Double, isSyncOpponent: Bool = false) {
        guard let currentSecs = currentTime?.seconds else { return }
        let secsDiff = seconds - currentSecs // シーク前に計算しておかないとcurrentSecsが変わってしまうのでここで計算
        
        let time = CMTime(seconds: seconds, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        player?.seek(to: time, toleranceBefore: .zero, toleranceAfter: .zero, completionHandler: { _ in })
        if !isSyncOpponent { playersModel.syncSeekIfSyncMode(opponent: side.theOtherSide!, secsDiff: secsDiff) }
    }
    func seekBy(_ secsDiff: Double, isSyncOpponent: Bool = false) {
        if currentTime == nil || duration == nil { return }

        var seconds = currentTime!.seconds + secsDiff
        if seconds < 0 { seconds = 0 }
        if seconds > duration!.seconds { seconds = duration!.seconds }

        seekTo(seconds, isSyncOpponent: isSyncOpponent)
    }
    func seek5SecsForward() { seekBy(5) }
    func seek5SecsBackward() { seekBy(-5) }
    
    func setTrimmingStart() {
        trimmingStartSecs = currentTime?.seconds
    }

    // Bug②: freeze end point before the save dialog opens
    func setTrimmingEnd() {
        trimmingEndSecs = currentTime?.seconds
    }

    func cancelTrimming() {
        trimmingStartSecs = nil
        trimmingEndSecs = nil
    }
    
    func trim(exportUrl: URL) async {
        guard let sourceUrl = self.fileURL,
              let trimmingStartSecs = trimmingStartSecs,
              let trimmingEndSecs = trimmingEndSecs   // Bug②: use frozen end time
        else { return }
        
        self.isExecutingTrimming = true
        defer {
            self.isExecutingTrimming = false
            self.trimmingStartSecs = nil
            self.trimmingEndSecs = nil
        }
        
        // トリミング開始時間と終了時間を取得
        var startSecs: Double
        var endSecs: Double
        if trimmingStartSecs < trimmingEndSecs {
            startSecs = trimmingStartSecs
            endSecs = trimmingEndSecs
        } else {
            startSecs = trimmingEndSecs
            endSecs = trimmingStartSecs
        }
        
        // アセットの作成
        let asset = AVURLAsset(url: sourceUrl)

        do {
            // 動画のアセットとトラックを作成
            let videoTrack = try await asset.loadTracks(withMediaType: .video)[0]
            // 音声が無い動画の場合も考慮
            var audioTrack: AVAssetTrack? = nil
            let audioTracks = try await asset.loadTracks(withMediaType: .audio)
            if !audioTracks.isEmpty {
                audioTrack = audioTracks[0]
            }

            // コンポジション作成
            let mixComposition = AVMutableComposition()
            // ベースとなる動画のコンポジション作成
            let compositionVideoTrack: AVMutableCompositionTrack! = mixComposition.addMutableTrack(withMediaType: .video, preferredTrackID: kCMPersistentTrackID_Invalid)
            var compositionAudioTrack: AVMutableCompositionTrack? = nil
            if audioTrack != nil {
                // ベースとなる音声のコンポジション作成
                compositionAudioTrack = mixComposition.addMutableTrack(withMediaType: .audio, preferredTrackID: kCMPersistentTrackID_Invalid)
            }
                
            // 動画と音声の長さ設定 -> 精度を上げるためvalueとtimescale両方にNSEC_PER_SECを掛け算
            let startTime = CMTime(value: CMTimeValue(startSecs * Double(NSEC_PER_SEC)),
                                   timescale: CMTimeScale(NSEC_PER_SEC))
            let newDuration = CMTime(value: CMTimeValue((endSecs - startSecs) * Double(NSEC_PER_SEC)),
                                     timescale: CMTimeScale(NSEC_PER_SEC))
            try compositionVideoTrack.insertTimeRange(CMTimeRangeMake(start: startTime, duration: newDuration), of: videoTrack, at: .zero)
            if audioTrack != nil {
                try compositionAudioTrack!.insertTimeRange(CMTimeRangeMake(start: startTime, duration: newDuration), of: audioTrack!, at: .zero)
            }
            // 回転方向の設定
            compositionVideoTrack.preferredTransform = try await videoTrack.load(.preferredTransform)
            // 動画のサイズを取得
            let videoSize = try await videoTrack.load(.naturalSize)

            // 合成用コンポジション作成
            let videoComposition = AVMutableVideoComposition()
            videoComposition.renderSize = videoSize
            videoComposition.frameDuration = CMTimeMake(value: 1, timescale: 30)

            // インストラクションを合成用コンポジションに設定
            let instruction = AVMutableVideoCompositionInstruction()
            instruction.timeRange = CMTimeRangeMake(start: .zero, duration: newDuration)
            let layerInstruction = AVMutableVideoCompositionLayerInstruction(assetTrack: compositionVideoTrack)
            instruction.layerInstructions = [ layerInstruction ]
            videoComposition.instructions = [ instruction ]

            // 動画のコンポジションをベースにAVAssetExportを生成
            guard let assetExport = AVAssetExportSession(asset: mixComposition, presetName: AVAssetExportPresetHighestQuality) else {
                throw NSError(domain: "couldn't get AVAssetExportSettion", code: -1, userInfo: nil)
            }

            // 合成用コンポジションを設定
            assetExport.videoComposition = videoComposition

            // Bug①: explicit audio mix prevents crackling during re-encode
            if let compositionAudioTrack = compositionAudioTrack {
                let audioMixInputParams = AVMutableAudioMixInputParameters(track: compositionAudioTrack)
                audioMixInputParams.setVolume(1.0, at: .zero)
                let audioMix = AVMutableAudioMix()
                audioMix.inputParameters = [audioMixInputParams]
                assetExport.audioMix = audioMix
            }

            // エクスポートファイルの設定
            assetExport.outputFileType = .mp4
            assetExport.outputURL = exportUrl
            assetExport.shouldOptimizeForNetworkUse = true

            // ファイルが存在している場合は削除しないとエラーになる
            let path = exportUrl.pathMacOSVersionFree
            if FileManager.default.fileExists(atPath: path) {
                try FileManager.default.removeItem(atPath: path)
            }

            // エクスポート実行
            await assetExport.export()
            self.trimmingErrorMsg = assetExport.error?.localizedDescription
            self.trimmingStatus = assetExport.status
            
            // ファイルの存在確認後、動画を新規ウィンドウで開く
            if FileManager.default.fileExists(atPath: path) {
                Task { @MainActor in
                    let storyboard = NSStoryboard(name: "Main", bundle: nil)
                    guard let windowController = storyboard.instantiateController(withIdentifier: "PlayersWindowID") as? MainWindowController,
                          let viewController = windowController.contentViewController as? MainViewController else { return }
                    viewController.doubleClickedFileUrl = exportUrl
                    windowController.showWindow(self)
                }
            }
            
        } catch {
            self.trimmingErrorMsg = error.localizedDescription
            self.trimmingStatus = nil
            return
        }
    }
    
    func clearTrimmingErrorMsgAndStatus() {
        self.trimmingErrorMsg = nil
        self.trimmingStatus = nil
    }
}

