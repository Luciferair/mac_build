//
//  PenToolFrozenFrameMovie.swift
//  SoccerCut Pro
//
//  Created by Naoki Tanaka on 2023/10/02.
//

import Cocoa
import SwiftUI

class PenToolFrozenFrameMovie {
    let frameSecs: Double
    let fileUrl: URL
    
    init(frameSecs: Double, fileUrl: URL) {
        self.frameSecs = frameSecs
        self.fileUrl = fileUrl
    }
}
