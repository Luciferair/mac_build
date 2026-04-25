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

        await MainActor.run {
            self.isExecutingTrimming = true
            self.trimmingErrorMsg = nil
            self.trimmingStatus = nil
        }
        defer {
            Task { @MainActor in
                self.isExecutingTrimming = false
                self.trimmingStartSecs = nil
                self.trimmingEndSecs = nil
            }
        }
 
        let startSecs = min(trimmingStartSecs, trimmingEndSecs)
        let endSecs = max(trimmingStartSecs, trimmingEndSecs)
        let durationSecs = endSecs - startSecs
        if durationSecs <= 0 {
            await MainActor.run {
                self.trimmingErrorMsg = "切り出し範囲が正しくありません。"
                self.trimmingStatus = .failed
            }
            return
        }

        let asset = AVURLAsset(url: sourceUrl)
        let startTime = CMTime(seconds: startSecs, preferredTimescale: 600)
        let duration = CMTime(seconds: durationSecs, preferredTimescale: 600)
        let timeRange = CMTimeRange(start: startTime, duration: duration)

        let presets = [
            AVAssetExportPresetPassthrough,
            AVAssetExportPresetHighestQuality,
            AVAssetExportPresetMediumQuality
        ]
        var lastError: String? = nil
        var lastStatus: AVAssetExportSession.Status = .failed
        let path = exportUrl.pathMacOSVersionFree

        for preset in presets {
            guard let exporter = AVAssetExportSession(asset: asset, presetName: preset) else { continue }
            guard let outputFileType = preferredOutputFileType(for: exporter, exportUrl: exportUrl) else { continue }

            do {
                if FileManager.default.fileExists(atPath: path) {
                    try FileManager.default.removeItem(atPath: path)
                }
            } catch {
                lastError = error.localizedDescription
                continue
            }

            exporter.outputURL = exportUrl
            exporter.outputFileType = outputFileType
            exporter.timeRange = timeRange
            exporter.shouldOptimizeForNetworkUse = (preset != AVAssetExportPresetPassthrough)
            await exporter.export()

            if exporter.status == .completed {
                await MainActor.run {
                    self.trimmingErrorMsg = nil
                    self.trimmingStatus = .completed
                }
                if FileManager.default.fileExists(atPath: path) {
                    await MainActor.run {
                        let storyboard = NSStoryboard(name: "Main", bundle: nil)
                        guard let windowController = storyboard.instantiateController(withIdentifier: "PlayersWindowID") as? MainWindowController,
                              let viewController = windowController.contentViewController as? MainViewController else { return }
                        viewController.doubleClickedFileUrl = exportUrl
                        windowController.showWindow(self)
                    }
                }
                return
            }

            lastError = exporter.error?.localizedDescription
            lastStatus = exporter.status
            try? FileManager.default.removeItem(atPath: path)
        }

        await MainActor.run {
            self.trimmingErrorMsg = lastError ?? "動画の書き出しに失敗しました。"
            self.trimmingStatus = lastStatus
        }
    }

    private func preferredOutputFileType(for exporter: AVAssetExportSession, exportUrl: URL) -> AVFileType? {
        let supported = exporter.supportedFileTypes
        if supported.isEmpty { return nil }

        let ext = exportUrl.pathExtension.lowercased()
        if ext == "mp4" {
            return supported.contains(.mp4) ? .mp4 : nil
        }
        if ext == "mov" {
            return supported.contains(.mov) ? .mov : nil
        }

        if supported.contains(.mp4) { return .mp4 }
        if supported.contains(.mov) { return .mov }
        return supported.first
    }
    
    func clearTrimmingErrorMsgAndStatus() {
        self.trimmingErrorMsg = nil
        self.trimmingStatus = nil
    }
}

