//
//  PenToolPlayerViewModel.swift
//  SoccerCut Pro
//
//  Created by Naoki Tanaka on 2023/08/31.
//

import AVFoundation
import Cocoa

class PenToolPlayerViewModel: ObservableObject {
    private(set) var player: PenToolPlayer!
    private var pathHistory: PenToolPathHistory!
                
    func initialize() {
        player = PenToolModel.now.player
        pathHistory = PenToolModel.now.pathHistory
    }
    
    func onClickTogglePlayPauseMenu() { player.togglePlayPause() }
    func onClickSkipMenu(rate: Float? = nil) { player.skip(rate: rate) }
    func onClickRewindMenu(rate: Float? = nil) { player.rewind(rate: rate) }
    func onClickSeek5SecsForwardMenu() { player.seek5SecsForward() }
    func onClickSeek5SecsBackwardMenu() { player.seek5SecsBackward() }
    func onClickStepForwardMenu() { player.stepForward() }
    func onClickStepBackwardMenu() { player.stepBackward() }
    
    func onClickUndoMenu() { pathHistory.undo() }
    func onClickRedoMenu() { pathHistory.redo() }
    func onClickRemoveSelectedPathMenu() { pathHistory.removeSelectedPath() }
}
