//
//  PlayersModel.swift
//  SoccerCut Pro
//
//  Created by Naoki Tanaka on 2023/06/07.
//

import AVFoundation
import Cocoa
import SwiftUI

class PlayersModel {
    private(set) var both: [PlayerModel] = []
    var left: PlayerModel { both.first(where: { $0.side == .left })! }
    var right: PlayerModel { both.first(where: { $0.side == .right })! }
    var bothPlayersAreReady: Bool { both.allSatisfy { $0.player != nil } }
    private(set) var isSyncMode: Bool = false
    private(set) var audioSide: ScreenSides? = nil
    
    var lastlyActivatedTarget: PlayerModel? { // 操作した時間が新しい方
        var target: PlayerModel? = nil
        for playerModel in both {
            if playerModel.player == nil { continue }
            else if target == nil { target = playerModel }
            else { target = target!.lastlyActivatedViewTime < playerModel.lastlyActivatedViewTime ? playerModel : target }
        }

        return target
    }
    
    var nextEmptySide: ScreenSides? {
        if left.player == nil { return .left }
        else if right.player == nil { return .right }
        return nil
    }
    
    func initialize(selfs: [PlayerModel]) {
        both = selfs
    }
    
    func addObserversIfBothPlayersHaveGetReady() {
        if nextEmptySide != nil { return }
        
        right.setIsMuted(true)
        NotificationCenter.default.addObserver(self, selector: #selector(self.syncRateIfSyncMode),
                                               name: AVPlayer.rateDidChangeNotification,
                                               object: left.player!)
        NotificationCenter.default.addObserver(self, selector: #selector(self.syncRateIfSyncMode),
                                               name: AVPlayer.rateDidChangeNotification,
                                               object: right.player!)
    }
    
    func restoreCurrentPlayerItems() {
        both.forEach { $0.restoreCurrentPlayerItem() }
    }
    
    @objc func syncRateIfSyncMode(notification: NSNotification) {
        if !isSyncMode || left.player!.rate == right.player!.rate { return } // NotificationCenterが発火して無限ループに入るのを防止
        guard let sourcePlayer = notification.object as? AVPlayer else { return }
        if left.player! == sourcePlayer {
            right.player!.rate = left.player!.rate
        } else {
            left.player!.rate = right.player!.rate
        }
    }
    // rateが関係する処理はSyncモード時に両画面を操作するとバグるので、片方だけ操作して後はonChangeRateに任せる
    func play() { lastlyActivatedTarget?.play() }
    func pause() { lastlyActivatedTarget?.pause() }
    func togglePlayPause() { lastlyActivatedTarget?.togglePlayPause() }
    func skip(rate: Float? = nil) { lastlyActivatedTarget?.skip(rate: rate) }
    func rewind(rate: Float? = nil) { lastlyActivatedTarget?.rewind(rate: rate) }
    
    // stepが関係する処理は手動で同期
    func syncStepIfSyncMode(opponent: ScreenSides, stepWidth: Int) {
        if !isSyncMode { return }
        opponent == .left ? left.step(stepWidth, isSyncOpponent: true)
                          : right.step(stepWidth, isSyncOpponent: true)
    }
    func stepForward() { lastlyActivatedTarget?.step(1) }
    func stepBackward() { lastlyActivatedTarget?.step(-1) }
    
    // seekが関係する処理は手動で同期
    func syncSeekIfSyncMode(opponent: ScreenSides, secsDiff: Double) {
        if !isSyncMode { return }
        opponent == .left ? left.seekBy(secsDiff, isSyncOpponent: true)
                          : right.seekBy(secsDiff, isSyncOpponent: true)
    }
    func seek5SecsForward() { lastlyActivatedTarget?.seek5SecsForward() }
    func seek5SecsBackward() { lastlyActivatedTarget?.seek5SecsBackward() }
    
    func switchAudio() {
        if !bothPlayersAreReady { return }
        
        audioSide = audioSide == .right ? .left : .right // 旧audioSideがboth/nilの場合もrightに切替
        left.setIsMuted(audioSide != .left)
        right.setIsMuted(audioSide != .right)
    }
    
    func switchSyncMode() {
        if !bothPlayersAreReady { return }
        
        isSyncMode.toggle()
        if !isSyncMode { return }
        
        if lastlyActivatedTarget!.side == .left && left.isPlaying { right.player!.rate = left.player!.rate }
        else if lastlyActivatedTarget!.side == .right && right.isPlaying { left.player!.rate = right.player!.rate }
    }
}
