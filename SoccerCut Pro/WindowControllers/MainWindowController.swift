//
//  MainWindowController.swift
//  SoccerCut Pro
//
//  Created by Naoki Tanaka on 2023/06/04.
//

import Cocoa

class MainWindowController: NSWindowController, NSWindowDelegate {
    override func windowWillLoad() {
        super.windowWillLoad()
    }
    
    override func windowDidLoad() {
        super.windowDidLoad()
        
        window?.collectionBehavior = .fullScreenPrimary
        window?.minSize = CGSize(width: 640, height: 480) // 小さくしすぎるとクラッシュするので回避
    }
        
    func windowDidMiniaturize(_ notification: Notification) {
        (contentViewController as? MainViewController)?.onDidMiniaturizeWindow()
    }
    
    func windowWillClose(_ notification: Notification) {
        //
    }
}
