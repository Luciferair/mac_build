//
//  CGPoint+.swift
//  SoccerCut Pro
//
//  Created by Naoki Tanaka on 2023/06/08.
//

import Cocoa

extension CGPoint {
    static func + (left: CGPoint, right: CGPoint) -> CGPoint {
        return CGPoint(x: left.x + right.x, y: left.y + right.y)
    }
    
    static func - (left: CGPoint, right: CGPoint) -> CGPoint {
        return CGPoint(x: left.x - right.x, y: left.y - right.y)
    }
    
    static func * (left: CGPoint, right: CGFloat) -> CGPoint {
        return CGPoint(x: left.x * right, y: left.y * right)
    }

    static func * (left: CGFloat, right: CGPoint) -> CGPoint {
        return CGPoint(x: right.x * left, y: right.y * left)
    }
    
    var length: CGFloat {
        get { sqrt(self.x * self.x + self.y * self.y) }
    }
    
    var unit: CGPoint {
        get { self * (1.0 / self.length) }
    }
}
