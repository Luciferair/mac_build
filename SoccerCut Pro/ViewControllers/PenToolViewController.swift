//
//  PenToolViewController.swift
//  SoccerCut Pro
//
//  Created by Naoki Tanaka on 2023/07/28.
//

import Cocoa
import SwiftUI

class PenToolViewController: NSViewController {
    @IBOutlet weak var sceneRootView: PenToolSceneRootView!
    @IBOutlet weak var processingView: PenToolProcessingView!
    
    static var fileUrl: URL? = nil
    
    var playerView: PenToolPlayerView { get { return sceneRootView.playerScreen } }
    
    override func viewDidLoad() {
        super.viewDidLoad()
                
        // PlayerSceneから渡されたファイルのURLを検知したら初期化を実行
        var timeInterval = 0.01
        Timer.scheduledTimer(withTimeInterval: timeInterval, repeats: true, block: { (timer) in
            guard let fileUrl = PenToolViewController.fileUrl else { return }
            
            PenToolModel.initialize(fileUrl: fileUrl) // 新しいウィンドウが開く度に初期化
            self.sceneRootView.initialize(processingView: self.processingView)
            
            // ウィンドウのタイトル（ファイル名）設定
            let fileName = PenToolViewController.fileUrl!.lastPathComponent
            self.view.window!.title = fileName
            
            PenToolViewController.fileUrl = nil
            timer.invalidate()
        })
        
        // キーボード入力受付ウィンドウ変更検知
        timeInterval = 0.1
        Timer.scheduledTimer(withTimeInterval: timeInterval, repeats: true, block: { (timer) in
            if (NSApplication.shared.keyWindow?.contentViewController != self) { return }
            // キーウィンドウになったことを検知
            NotificationCenter.default.addObserver(self,
                                                   selector: #selector(self.onBecomeKeyWindow),
                                                   name: NSWindow.didBecomeKeyNotification,
                                                   object: NSApplication.shared.keyWindow)
            // 初回だけ発火しないので手動で実行
            AppDelegate.instance.switchMenuMode(appMode: .penTool)
            
            // キーウィンドウではなくなったことを検知
            NotificationCenter.default.addObserver(self,
                                                   selector: #selector(self.onResignKeyWindow),
                                                   name: NSWindow.didResignKeyNotification,
                                                   object: NSApplication.shared.keyWindow)
            
            timer.invalidate()
        })
    }
    
    @objc func onBecomeKeyWindow() {
        AppDelegate.instance.switchMenuMode(appMode: .penTool, currentPenToolType: sceneRootView.currentPenToolType())
    }
    
    @objc func onResignKeyWindow() {
        NSColorPanel.shared.close()
    }

    @IBAction func onClickOKInProcessingView(_ sender: NSButton) {
        sceneRootView.onClickOKInDialog()
    }
}
