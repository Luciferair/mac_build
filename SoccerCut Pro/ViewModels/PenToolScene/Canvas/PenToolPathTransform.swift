//
//  PenToolPathTransform.swift
//  SoccerCut Pro
//
//  Created by Naoki Tanaka on 2024/04/10.
//

import SwiftUI

class PenToolPathTransform: ObservableObject {
    @Published var start: CGPoint = .zero
    @Published var end: CGPoint = .zero
    @Published var draggingOffset: CGSize = .zero
    
    func copyValues(from: PenToolPathTransform) {
        self.start = from.start
        self.end = from.end
        self.draggingOffset = from.draggingOffset
    }
}
