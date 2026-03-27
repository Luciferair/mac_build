//
//  NSEvent+.swift
//  SoccerCut Pro
//
//  Created by Naoki Tanaka on 2023/06/08.
//

import Cocoa

extension NSEvent {
    var locationInCGWindow: CGPoint {
        guard let windowHeight = window?.frame.size.height else { return .zero }
        
        // 左下基準&右上が+ -> 左上基準&右下が+に変換
        var location = locationInWindow
        location.y = windowHeight - location.y
        
        return location
    }
}
