//
//  PenToolDrawnPathViewModel.swift
//  SoccerCut Pro
//
//  Created by Naoki Tanaka on 2023/12/05.
//

import SwiftUI

class PenToolDrawnPathViewModel: ObservableObject {
    private let pathFactory: PenToolPathFactory
    @Published var isSelected = false
    
    init() {
        pathFactory = PenToolModel.now.pathFactory
    }
    
    func currentType() -> PenToolType {
        return pathFactory.currentType
    }
}
