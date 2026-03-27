//
//  MainViewController.swift
//  SoccerCut Pro
//
//  Created by Naoki Tanaka on 2023/05/21.
//

import Cocoa
import SwiftUI

class MainViewController: NSViewController {
    private let defaultWindowTitle: String = Bundle.main.object(forInfoDictionaryKey: "CFBundleDisplayName") as? String ?? "SoccerCut Pro"
    
    var doubleClickedFileUrl: URL? = nil
    @IBOutlet weak var processingView: ProcessingView!
    @IBOutlet weak var playersView: PlayersView!
    @IBOutlet weak var playerViewLeft: PlayerView!
    @IBOutlet weak var playerViewRight: PlayerView!
    @State private var playersViewModel: PlayersViewModel = PlayersViewModel()
    @State private var playerViewModelLeft: PlayerViewModel = PlayerViewModel()
    @State private var playerViewModelRight: PlayerViewModel = PlayerViewModel()
    private var playersModel: PlayersModel!
    private var playerModelLeft: PlayerModel!
    private var playerModelRight: PlayerModel!
    private var windowTitleLeft: String? = nil
    private var windowTitleRight: String? = nil
    
    var getHasLoadedAtLeastOneFile: Bool { self.playerModelLeft.player != nil || self.playerModelRight.player != nil }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Model
        playersModel = PlayersModel()
        playerModelLeft = PlayerModel(side: .left, playersModel: playersModel)
        playerModelRight = PlayerModel(side: .right, playersModel: playersModel)
        playersModel.initialize(selfs: [playerModelLeft, playerModelRight])
        
        // ViewModel
        playerViewModelLeft.initialize(side: .left, playersViewModel: playersViewModel, playerModel: playerModelLeft)
        playerViewModelRight.initialize(side: .right, playersViewModel: playersViewModel, playerModel: playerModelRight)
        playersViewModel.initialize(selfs: [playerViewModelLeft, playerViewModelRight], playersModel: playersModel)
        
        // 保存処理中画面
        processingView.hide()
        
        // View
        playerViewLeft.initialize(side: .left, playersView: playersView,
                                  playerViewModel: playerViewModelLeft, processingView: processingView)
        playerViewRight.initialize(side: .right, playersView: playersView,
                                   playerViewModel: playerViewModelRight, processingView: processingView)
        playersView.initialize(selfs: [playerViewLeft, playerViewRight], playersViewModel: playersViewModel)
        
        // ウィンドウのタイトル（ファイル名）検知
        var timeInterval = 0.2
        Timer.scheduledTimer(withTimeInterval: timeInterval, repeats: true, block: { (timer) in
            if self.windowTitleLeft == nil && self.playerModelLeft.fileURL != nil {
                let fileName = self.playerModelLeft.fileURL!.lastPathComponent
                self.windowTitleLeft = fileName
                guard let windowTitle = self.view.window?.title else { return }
                self.view.window!.title = windowTitle == self.defaultWindowTitle ? fileName : "\(fileName)  |  \(windowTitle)"
            }
            if self.windowTitleRight == nil && self.playerModelRight.fileURL != nil {
                let fileName = self.playerModelRight.fileURL!.lastPathComponent
                self.windowTitleRight = fileName
                guard let windowTitle = self.view.window?.title else { return }
                self.view.window!.title = windowTitle == self.defaultWindowTitle ? fileName : "\(windowTitle)  |  \(fileName)"
            }
            
            if self.windowTitleLeft == nil || self.windowTitleRight == nil { return }
            timer.invalidate()
        })        
        
        // ダブルクリックされたファイルの検知
        timeInterval = 0.01
        Timer.scheduledTimer(withTimeInterval: timeInterval, repeats: true, block: { (timer) in
            if self.getHasLoadedAtLeastOneFile { timer.invalidate() }
            guard let fileUrl = self.doubleClickedFileUrl else { return }
            self.playerViewLeft.onSelectFile(url: fileUrl)
            self.doubleClickedFileUrl = nil
            timer.invalidate()
        })
        
        // キーボード入力受付ウィンドウ変更検知
        timeInterval = 0.1
        Timer.scheduledTimer(withTimeInterval: timeInterval, repeats: true, block: { (timer) in
            if (NSApplication.shared.keyWindow?.contentViewController != self) { return }
            NotificationCenter.default.addObserver(self,
                                                   selector: #selector(self.onBecomeKeyWindow),
                                                   name: NSWindow.didBecomeKeyNotification,
                                                   object: NSApplication.shared.keyWindow)
            // 初回だけ発火しないので手動で実行
            AppDelegate.instance.switchMenuMode(appMode: .player)
            
            timer.invalidate()
        })
    }
    
    override func viewWillDisappear() {
        // ウィンドウを閉じても音声が再生され続ける問題を回避
        playerModelLeft.player?.replaceCurrentItem(with: nil)
        playerModelRight.player?.replaceCurrentItem(with: nil)
    }
    
    @objc func onBecomeKeyWindow() {
        AppDelegate.instance.switchMenuMode(appMode: .player)
    }
    
    func onDidMiniaturizeWindow() {
        playersModel.restoreCurrentPlayerItems()
    }
    
    @IBAction func onClickOKInProcessingView(_ sender: NSButton) {
        // TODO 処理する場所はここじゃないほうがよさそう
        playersView.clickOKInProcessingView()
        processingView.hide()
    }
}
