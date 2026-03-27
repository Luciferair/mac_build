//
//  ProcessingView.swift
//  SoccerCut Pro
//
//  Created by Naoki Tanaka on 2023/06/01.
//

import AVFoundation
import Cocoa

class ProcessingView: NSView {
    private var indicator: NSProgressIndicator!
    private var label: NSTextField!
    private var button: NSButton!
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        initialize()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        initialize()
    }
    
    private func initialize() {
        indicator = getSubView(checkClass: NSProgressIndicator())
        label = getSubView(checkClass: NSTextField())
        button = getSubView(checkClass: NSButton())
    }
    
    func show() {
        let menuItems = NSApplication.shared.mainMenu?.items
        if menuItems != nil { menuItems?.forEach({ $0.isEnabled = false }) }
        
        isHidden = false
        indicator.isHidden = false
        indicator.startAnimation(nil)
        label.stringValue = "動画を保存中です。\nこの処理は数分かかることがあります。"
    }
    
    func waitForClick(errorMsg: String? = nil, statusCode: AVAssetExportSession.Status? = nil) {
        indicator.stopAnimation(nil)
        indicator.isHidden = true
        
        if statusCode == .failed || errorMsg != nil {
            label.stringValue = "動画の保存に失敗しました。\nエラー：\(errorMsg)"
        }
        else if statusCode == .completed {
            label.stringValue = "動画の保存に成功しました！"
        }
        else {
            label.stringValue = "動画の保存の結果を確認できませんでした。\nお手数ですが実際にファイルを開いて確認してください。\nステータスコード: \(statusCode?.rawValue)"
        }

        button.isHidden = false
    }
    
    func hide() {
        let menuItems = NSApplication.shared.mainMenu?.items
        if menuItems != nil { menuItems?.forEach({ $0.isEnabled = true }) }
        
        label.stringValue = ""
        button.isHidden = true
        isHidden = true
    }
}
