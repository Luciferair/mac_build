//
//  NSWindow+.swift
//  SoccerCut Pro
//
//  Created by Naoki Tanaka on 2023/06/09.
//

import Cocoa

extension NSWindow {
    var isFullScreen: Bool {
        return self.styleMask.contains(.fullScreen)
    }
}
