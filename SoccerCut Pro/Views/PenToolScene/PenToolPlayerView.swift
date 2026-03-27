//
//  PenToolPlayerView.swift
//  SoccerCut Pro
//
//  Created by Naoki Tanaka on 2023/07/28.
//

import AVFoundation
import Cocoa
import SwiftUI

class PenToolPlayerView: NSView {
    @ObservedObject private(set) var viewModel = PenToolPlayerViewModel()
    private(set) var playerLayer: AVPlayerLayer?
    
    private var controlsHV: NSHostingView<PenToolPlayerControlsPanel>?
    
    override init(frame: CGRect) { super.init(frame: frame) }
    required init?(coder aDecoder: NSCoder) { super.init(coder: aDecoder) }

    func initialize(controlsHV: NSHostingView<PenToolPlayerControlsPanel>) {
        self.controlsHV = controlsHV
        viewModel.initialize()
        
        playerLayer = AVPlayerLayer(player: viewModel.player)
        playerLayer!.videoGravity = .resizeAspect
        wantsLayer = true
        layer?.addSublayer(playerLayer!)
        makeLayerAndItsSublayersTheSameFrameAsMe()
        
        // playerLayerが再生準備完了＝サイズを持つようになったらリサイズ通知
        let timeInterval = 0.01
        Timer.scheduledTimer(withTimeInterval: timeInterval, repeats: true, block: { (timer) in
            guard let playerLayer = self.playerLayer else { return }
            if !playerLayer.isReadyForDisplay { return }
            NotificationCenter.default.post(name: NSView.frameDidChangeNotification, object: nil)
            timer.invalidate()
        })
    }
    
    func clickCloseWindowMenu() { NSApplication.shared.keyWindow?.close() }
    func clickTogglePlayPauseMenu() { viewModel.onClickTogglePlayPauseMenu() }
    func clickSkipMenu(rate: Float? = nil) { viewModel.onClickSkipMenu(rate: rate) }
    func clickRewindMenu(rate: Float? = nil) { viewModel.onClickRewindMenu(rate: rate) }
    func clickSeek5SecsForwardMenu() { viewModel.onClickSeek5SecsForwardMenu() }
    func clickSeek5SecsBackwardMenu() { viewModel.onClickSeek5SecsBackwardMenu() }
    func clickStepForwardMenu() { viewModel.onClickStepForwardMenu() }
    func clickStepBackwardMenu() { viewModel.onClickStepBackwardMenu() }
    
    func clickUndoMenu() { viewModel.onClickUndoMenu() }
    func clickRedoMenu() { viewModel.onClickRedoMenu() }
    func clickRemoveSelectedPathMenu() { viewModel.onClickRemoveSelectedPathMenu() }
}
