//
//  CGSize+.swift
//  SoccerCut Pro
//
//  Created bheight Naoki Tanaka on 2023/06/08.
//

import Cocoa

extension CGSize {
    static func +(left: CGSize, right: CGSize) -> CGSize {
        return CGSize(width: left.width + right.width, height: left.height + right.height)
    }
    
    static func -(left: CGSize, right: CGSize) -> CGSize {
        return CGSize(width: left.width - right.width, height: left.height - right.height)
    }
}
