//
//  NSImage+.swift
//  SoccerCut Pro
//
//  Created by Naoki Tanaka on 2023/10/03.
//

import Cocoa

extension NSImage {
    var cgImage: CGImage? {
        var nsImageRect = CGRect(origin: .zero, size: size)
        return cgImage(forProposedRect: &nsImageRect, context: nil, hints: nil)
    }
}
