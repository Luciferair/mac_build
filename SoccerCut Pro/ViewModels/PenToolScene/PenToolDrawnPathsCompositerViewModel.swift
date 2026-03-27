//
//  PenToolDrawnPathsCompositerViewModel.swift
//  SoccerCut Pro
//
//  Created by Naoki Tanaka on 2023/10/02.
//

import Cocoa
import SwiftUI

class PenToolDrawnPathsCompositerViewModel: ObservableObject {
    @Published private(set) var paths: [PenToolDrawnPath]
    @Published private(set) var resolution: CGSize
    
    init(paths: [PenToolDrawnPath], resolution: CGSize) {
        self.paths = paths
        self.resolution = resolution
    }
}
