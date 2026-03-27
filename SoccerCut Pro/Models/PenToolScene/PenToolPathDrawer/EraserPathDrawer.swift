//
//  EraserPathDrawer.swift
//  SoccerCut Pro
//
//  Created by Naoki Tanaka on 2023/08/18.
//

import Cocoa
import SwiftUI

struct EraserPathDrawer: PenToolPathDrawerProtocol {
    var style = PenToolPathStyle(isEraser: true)
    
    func isValidInput(startInResolution: CGPoint, endInResolution: CGPoint) -> Bool {
        return false // 何も描画しないので常にfalse
    }
    
    func makePath(startInResolution: CGPoint, endInResolution: CGPoint) -> any PenToolPathProtocol {
        return EraserPath()
    }
    
    func saveStyle() {
        // do nothing
    }
}
