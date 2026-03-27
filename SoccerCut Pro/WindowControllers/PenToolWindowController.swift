//
//  PenToolWindowController.swift
//  SoccerCut Pro
//
//  Created by Naoki Tanaka on 2023/07/28.
//

import Cocoa

class PenToolWindowController: NSWindowController, NSWindowDelegate {
    override func windowWillLoad() {
        super.windowWillLoad()
    }
    
    override func windowDidLoad() {
        super.windowDidLoad()
        
        window?.collectionBehavior = .fullScreenPrimary
        window?.minSize = CGSize(width: 640, height: 480) // 小さくしすぎるとクラッシュするので回避
    }
    
    func windowDidMiniaturize(_ notification: Notification) {
        // TODO 最小化した時の対応
//        (contentViewController as? MainViewController)?.onDidMiniaturizeWindow()
    }
    
    func windowWillClose(_ notification: Notification) {
        // TODO 保存せずにウィンドウを閉じようとした時に保存を促すアラートを表示
    }
}
