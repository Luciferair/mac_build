//
//  CGRect+.swift
//  SoccerCut Pro
//
//  Created by Naoki Tanaka on 2023/06/08.
//

import Cocoa

extension CGRect {
    // CGRect同士
    static func +(left: CGRect, right: CGRect) -> CGRect {
        return CGRect(origin: left.origin + right.origin, size: left.size + right.size)
    }
    
    static func -(left: CGRect, right: CGRect) -> CGRect {
        return CGRect(origin: left.origin - right.origin, size: left.size - right.size)
    }
}
