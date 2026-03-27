//
//  EraserPath.swift
//  SoccerCut Pro
//
//  Created by Naoki Tanaka on 2023/09/01.
//

import SwiftUI

struct EraserPath: View, PenToolPathProtocol {
    let type: PenToolType = .eraser
    
    func resize() {}
    func drawnStyle() -> PenToolPathStyle { return PenToolPathStyle() }
    func applyStyle(_ newStyle: PenToolPathStyle) {}
    func drawnTransform() -> PenToolPathTransform { return PenToolPathTransform() }
    func applyTransform(_ newTransform: PenToolPathTransform) {}
    func offset() -> CGSize { return .zero }
    func frame() -> CGSize { return .zero }
    func onDragged(startInVideoRect: CGPoint, endInVideoRect: CGPoint) {}
    func onDragEnded(startInVideoRect: CGPoint, endInVideoRect: CGPoint) {}
    
    var body: some View {
        EmptyView()
    }
}

struct EraserPath_Previews: PreviewProvider {
    static var previews: some View {
        EraserPath()
    }
}
