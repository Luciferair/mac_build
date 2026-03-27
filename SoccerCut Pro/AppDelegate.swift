//
//  AppDelegate.swift
//  SoccerCut Pro
//
//  Created by Naoki Tanaka on 2023/05/20.
//

import Cocoa
import StoreKit

@main
class AppDelegate: NSObject, NSApplicationDelegate {
    static var instance: AppDelegate!

    // ダブルクリックでファイルが開かれた時にURLを受け取る
    func application(_ app: NSApplication, open urls: [URL]) {
        for url in urls {
            // アプリ起動前->ファイルダブルクリックなど、まだデフォルトウィンドウにファイルがロードされていない場合
            if let firstViewController = app.mainWindow?.contentViewController as? MainViewController {
                if !firstViewController.getHasLoadedAtLeastOneFile && firstViewController.doubleClickedFileUrl == nil {
                    firstViewController.doubleClickedFileUrl = url
                    continue
                }
            }
            
            // デフォルトウィンドウにファイルがロードされている場合　新規ウィンドウを作成してロード
            let storyboard = NSStoryboard(name: "Main", bundle: nil)
            guard let windowController = storyboard.instantiateController(withIdentifier: "PlayersWindowID") as? MainWindowController,
                  let viewController = windowController.contentViewController as? MainViewController else { return }
            viewController.doubleClickedFileUrl = url
            windowController.showWindow(self)
        }
    }
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        AppDelegate.instance = self
        
        if ValidTransactions.instance.isSubscriptionApp() {
            ValidTransactions.instance.observeUpdates()
        }
    }
    
    func applicationWillBecomeActive(_ aNotification: Notification) {
        if !ValidTransactions.instance.isSubscriptionApp() { return }
        
        Task { @MainActor in
            // 購入済みサブスクリプションを一覧取得
            await ValidTransactions.instance.fetch()
            
            do {
                // 購入可能なサブスクリプションを一覧取得
                try await Products.instance.fetch()
            } catch {
                let alert = NSAlert()
                alert.alertStyle = .critical
                alert.messageText = "購入可能なサブスクリプションの一覧取得エラー"
                alert.informativeText = error.localizedDescription
                alert.addButton(withTitle: "アプリを終了")
                alert.runModal()
                
                NSApplication.shared.terminate(self)
                return
            }
            
            // サブスク購入があったか確認
            let purchaseDates = ValidTransactions.instance.purchaseDates
            let productIDs = ValidTransactions.instance.purchaseProductIds
            PurchaseChecker.checkPurchases(purchasedDates: purchaseDates, productIDs: productIDs)
            
            // 何か1つでもサブスクリプション購入済みであればアプリを使用可能
            if ValidTransactions.instance.containsAnyProductId() { return }
            
            // サブスクリプション選択画面を表示
            Products.instance.selection()
        }
    }
    
    static func setViewIsHidden(_ isHidden: Bool) {
        for window in NSApplication.shared.windows {
            // 全Viewを表示/非表示
            window.contentView?.isHidden = isHidden
            
            // 非表示にするとplayerが外れるので修復
            guard let mainVC = window.contentViewController as? MainViewController else { continue }
            mainVC.onDidMiniaturizeWindow()

            // TODO ペンツールの方もサブスクリプション選択画面を表示するなら修復が必要？
        }
    }
    
    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }

    func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
        return true
    }
    
    // ウィンドウを閉じるとアプリを終了させる
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return true
    }
    
    //  ========== メニューバー ==========
    
    @IBOutlet weak var menuSwitchSound: NSMenuItem!
    @IBOutlet weak var menuSwitchSyncMode: NSMenuItem!
    @IBOutlet weak var parentMenuTrimming: NSMenuItem!
    @IBOutlet weak var parentMenuPenTool: NSMenuItem!
    @IBOutlet weak var parentMenuSwitchScreen: NSMenuItem!
    @IBOutlet weak var menuGeneralUndo: NSMenuItem!
    @IBOutlet weak var menuGeneralRedo: NSMenuItem!
    @IBOutlet weak var menuPenToolUndo: NSMenuItem!
    @IBOutlet weak var menuPenToolRedo: NSMenuItem!
    @IBOutlet weak var menuPlayerStepForward: NSMenuItem!
    @IBOutlet weak var menuPlayerStepBackward: NSMenuItem!
    @IBOutlet weak var menuPlayerSkip2x: NSMenuItem!
    @IBOutlet weak var menuPlayerRewind2x: NSMenuItem!
    
    var getCurrentPlayersView: PlayersView? {
        let mainVC = NSApplication.shared.keyWindow?.contentViewController as? MainViewController
        return mainVC?.playersView
    }
    
    var getCurrentPenToolPlayerView: PenToolPlayerView? {
        let penToolVC = NSApplication.shared.keyWindow?.contentViewController as? PenToolViewController
        return penToolVC?.playerView
    }
    
    func switchMenuMode(appMode: ApplicationMode, currentPenToolType: PenToolType? = nil) {
        menuSwitchSound.isEnabled = appMode == .player
        menuSwitchSyncMode.isEnabled = appMode == .player
        parentMenuTrimming.isEnabled = appMode == .player
        parentMenuSwitchScreen.isEnabled = appMode == .player
        
        switchUndoRedo(isGeneral: appMode != .penTool)
        parentMenuPenTool.isHidden = appMode != .penTool
        parentMenuPenTool.isEnabled = appMode == .penTool
        
        menuPlayerStepForward.isEnabled = (appMode == .player || currentPenToolType != .text)
        menuPlayerStepBackward.isEnabled = (appMode == .player || currentPenToolType != .text)
    }
    
    // ファイル名入力等のUndo/Redo
    func switchUndoRedo(isGeneral: Bool) {
        if isGeneral {
            // PenToolのUndoと一般的なUndoはkeyEquivalentが同じで、同一のものは設定できないので付け替える
            menuPenToolUndo.keyEquivalent = ""
            menuGeneralUndo.keyEquivalent = "z"
            menuGeneralUndo.keyEquivalentModifierMask = NSEvent.ModifierFlags.command
        } else {
            menuGeneralUndo.keyEquivalent = ""
            menuPenToolUndo.keyEquivalent = "z"
            menuPenToolUndo.keyEquivalentModifierMask = NSEvent.ModifierFlags.command
        }
        
        menuGeneralUndo.isEnabled = isGeneral
        menuGeneralRedo.isEnabled = isGeneral
        menuPenToolUndo.isEnabled = !isGeneral
        menuPenToolRedo.isEnabled = !isGeneral
    }
    
    func switchPlayerStepAndSkipRewind(isEnabled: Bool) {
        menuPlayerStepForward.isEnabled = isEnabled
        menuPlayerStepBackward.isEnabled = isEnabled
        menuPlayerSkip2x.isEnabled = isEnabled
        menuPlayerRewind2x.isEnabled = isEnabled
    }
    
    @IBOutlet weak var menuBtnStartTrimming: NSMenuItem!
    @IBOutlet weak var menuBtnFinishTrimming: NSMenuItem!
    
    @IBAction func menuOpenFileWithPlayer(_ sender: NSMenuItem) { getCurrentPlayersView?.clickOpenFileMenu(appMode: .player) }
    @IBAction func menuOpenFileWithPenTool(_ sender: NSMenuItem) { getCurrentPlayersView?.clickOpenFileMenu(appMode: .penTool) }
    @IBAction func menuClose(_ sender: NSMenuItem) {
        getCurrentPlayersView?.clickCloseWindowMenu()
        getCurrentPenToolPlayerView?.clickCloseWindowMenu()
    }
    @IBAction func menuPlayPause(_ sender: NSMenuItem) {
        getCurrentPlayersView?.clickTogglePlayPauseMenu()
        getCurrentPenToolPlayerView?.clickTogglePlayPauseMenu()
    }
    @IBAction func menuSkip(_ sender: NSMenuItem) {
        getCurrentPlayersView?.clickSkipMenu()
        getCurrentPenToolPlayerView?.clickSkipMenu()
    }
    @IBAction func menuRewind(_ sender: NSMenuItem) {
        getCurrentPlayersView?.clickRewindMenu()
        getCurrentPenToolPlayerView?.clickRewindMenu()
    }
    @IBAction func menuSkip2x(_ sender: NSMenuItem) {
        getCurrentPlayersView?.clickSkipMenu(rate: PlayingState.skip2x.rawValue)
        getCurrentPenToolPlayerView?.clickSkipMenu(rate: PlayingState.skip2x.rawValue)
    }
    @IBAction func menuRewind2x(_ sender: NSMenuItem) {
        getCurrentPlayersView?.clickRewindMenu(rate: PlayingState.rewind2x.rawValue)
        getCurrentPenToolPlayerView?.clickRewindMenu(rate: PlayingState.rewind2x.rawValue)
    }
    @IBAction func menuSeek5SecsForward(_ sender: NSMenuItem) {
        getCurrentPlayersView?.clickSeek5SecsForwardMenu()
        getCurrentPenToolPlayerView?.clickSeek5SecsForwardMenu()
    }
    @IBAction func menuSeek5SecsBackward(_ sender: NSMenuItem) {
        getCurrentPlayersView?.clickSeek5SecsBackwardMenu()
        getCurrentPenToolPlayerView?.clickSeek5SecsBackwardMenu()
    }
    @IBAction func menuStepForward(_ sender: NSMenuItem) {
        getCurrentPlayersView?.clickStepForwardMenu()
        getCurrentPenToolPlayerView?.clickStepForwardMenu()
    }
    @IBAction func menuStepBackward(_ sender: NSMenuItem) {
        getCurrentPlayersView?.clickStepBackwardMenu()
        getCurrentPenToolPlayerView?.clickStepBackwardMenu()
    }
    @IBAction func menuStartTrimming(_ sender: NSMenuItem) { getCurrentPlayersView?.clickStartTrimmingMenu() }
    @IBAction func menuFinishTrimming(_ sender: NSMenuItem) { getCurrentPlayersView?.clickFinishTrimmingMenu() }
    
    @IBAction func menuPenToolUndo(_ sender: NSMenuItem) { getCurrentPenToolPlayerView?.clickUndoMenu() }
    @IBAction func menuPenToolRedo(_ sender: NSMenuItem) { getCurrentPenToolPlayerView?.clickRedoMenu() }
    @IBAction func menuPenToolRemoveSelectedPath(_ sender: NSMenuItem) { getCurrentPenToolPlayerView?.clickRemoveSelectedPathMenu() }
    
    @IBAction func menuToggleScreen1(_ sender: NSMenuItem) { getCurrentPlayersView?.clickToggleScreen1Menu() }
    @IBAction func menuToggleScreen2(_ sender: NSMenuItem) { getCurrentPlayersView?.clickToggleScreen2Menu() }
    @IBAction func menuSwitchAudio(_ sender: NSMenuItem) { getCurrentPlayersView?.clickSwitchAudioMenu() }
    @IBAction func menuSwitchSyncMode(_ sender: NSMenuItem) { getCurrentPlayersView?.clickSwitchSyncModeMenu() }
}
