//
//  PlayersView.swift
//  SoccerCut Pro
//
//  Created by Naoki Tanaka on 2023/05/23.
//

import AVFoundation
import Cocoa
import SwiftUI

class PlayersView: NSView {
    private(set) var playersViewModel: PlayersViewModel!
    private(set) var both: [PlayerView] = []
    var left: PlayerView { both.first(where: { $0.side == .left })! }
    var right: PlayerView { both.first(where: { $0.side == .right })! }
    private var nextEmptySide: ScreenSides? { playersViewModel.nextEmptySide }
    private var switchesHV: NSHostingView<DualSwitchesView>?
    var bothPlayersAreReady: Bool { both.allSatisfy { $0.player != nil } }
    var isSyncMode: Bool { playersViewModel.isSyncMode }
    
    func initialize(selfs: [PlayerView], playersViewModel: PlayersViewModel) {
        both = selfs
        self.playersViewModel = playersViewModel
        
        switchesHV = self.addSwiftUIView(DualSwitchesView(playersViewModel: playersViewModel))
        
        switchScreen(to: .left)
        
        // ウィンドウの位置・サイズ変更検知
        NotificationCenter.default.addObserver(self, selector: #selector(self.onResizeWindow), name: NSView.frameDidChangeNotification, object: nil)
    }
    
    @objc func onResizeWindow() {
        playersViewModel.viewFrame = frame
        let isDual = playersViewModel.showingScreenSides == .both
        switchesHV?.setFrameSize(bounds.size)
        for playerView in both {
            playerView.onResizeWindow(isDual: isDual)
        }
    }
    
    func prepareDefaultScreens(loadedSide: ScreenSides) {
        playersViewModel.nextEmptySide == nil ? switchScreen(to: .both) : switchScreen(to: loadedSide)
        // 最初の左画面をそのままフルスクリーンにするとescキーが効かない問題の応急処置
        if loadedSide == .left && playersViewModel.nextEmptySide != nil {
            switchScreen(to: .right)
            switchScreen(to: .left)
        }
    }
    
    func clickOpenFileMenu(appMode: ApplicationMode) {
        switch appMode{
        case .player:
            guard let side = playersViewModel.nextEmptySide else { return }
            side == .left ? left.openSelectFilePanel(appMode: appMode) : right.openSelectFilePanel(appMode: appMode)
            break
            
        case .penTool:
            right.openSelectFilePanel(appMode: appMode)
            break
        }
    }
    func clickCloseWindowMenu() { NSApplication.shared.keyWindow?.close() }
    func clickTogglePlayPauseMenu() { playersViewModel.onClickTogglePlayPauseMenu() }
    func clickSkipMenu(rate: Float? = nil) { playersViewModel.onClickSkipMenu(rate: rate) }
    func clickRewindMenu(rate: Float? = nil) { playersViewModel.onClickRewindMenu(rate: rate) }
    func clickSeek5SecsForwardMenu() { playersViewModel.onClickSeek5SecsForwardMenu() }
    func clickSeek5SecsBackwardMenu() { playersViewModel.onClickSeek5SecsBackwardMenu() }
    func clickStepForwardMenu() { playersViewModel.onClickStepForwardMenu() }
    func clickStepBackwardMenu() { playersViewModel.onClickStepBackwardMenu() }
    func clickStartTrimmingMenu() {
        guard let side = playersViewModel.trimmingTargetSide else { return }
        side == .left ? left.showTrimmingMarker(): right.showTrimmingMarker()
    }
    func clickFinishTrimmingMenu() {
        guard let side = playersViewModel.trimmingTargetSide else { return }
        side == .left ? left.openSaveFilePanel() : right.openSaveFilePanel()
    }
    func clickToggleScreen1Menu() { switchScreen(to: playersViewModel.showingScreenSides.nextIfToggleScreen1) }
    func clickToggleScreen2Menu() { switchScreen(to: playersViewModel.showingScreenSides.nextIfToggleScreen2) }
    func clickSwitchAudioMenu() { playersViewModel.onClickSwitchAudioBtn() }
    func clickSwitchSyncModeMenu() { playersViewModel.onClickSwitchSyncModeBtn() }
    
    func clickOKInProcessingView() { playersViewModel.onClickOKInProcessingView() }
    
    func switchScreen(to newScreenMode: ScreenSides) {
        playersViewModel.onSwitchScreen(to: newScreenMode)

        switch newScreenMode {
        case .both:
            for view in both {
                view.showScreenDual()
            }
            break
            
        case .left:
            left.showScreenSingle()
            right.hideScreen()
            break
            
        case .right:
            left.hideScreen()
            right.showScreenSingle()
            break
        }
    }
}
