//
//  PenToolPathDrawerProtocol.swift
//  SoccerCut Pro
//
//  Created by Naoki Tanaka on 2023/08/06.
//

import Cocoa
import SwiftUI

protocol PenToolPathDrawerProtocol {
    var style: PenToolPathStyle { get set }
    
    func isValidInput(startInResolution: CGPoint, endInResolution: CGPoint) -> Bool
    func makePath(startInResolution: CGPoint, endInResolution: CGPoint) -> any PenToolPathProtocol
    func saveStyle()
}

