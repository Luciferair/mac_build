//
//  CircleFillPath.swift
//  SoccerCut Pro
//
//  Created by Naoki Tanaka on 2023/10/31.
//

import SwiftUI

struct CircleFillPath: View, PenToolPathProtocol {
    let type: PenToolType = .circleFill
    private let pathHistory: PenToolPathHistory
    @ObservedObject private var _drawnStyle = PenToolPathStyle()
    @ObservedObject private var transform = PenToolPathTransform()
    
    init() {
        pathHistory = PenToolModel.now.pathHistory
    }
    
    func initialize(startInResolution: CGPoint, endInResolution: CGPoint) {
        self._drawnStyle.copyValues(from: PenToolModel.now.pathFactory.styleOf(type))
        
        self.transform.start = startInResolution
        self.transform.end = endInResolution
    }
    
    func drawnStyle() -> PenToolPathStyle { return _drawnStyle }
    func applyStyle(_ newStyle: PenToolPathStyle) { self._drawnStyle.copyValues(from: newStyle) }
    func drawnTransform() -> PenToolPathTransform { return transform }
    func applyTransform(_ newTransform: PenToolPathTransform) { transform.copyValues(from: newTransform) }
    
    func offset() -> CGSize { 
        return CGSize(width: transform.start.x - size().width/2, height: transform.start.y - size().height/2)
               + transform.draggingOffset
    }
    func frame() -> CGSize {
        return CGSize(width: size().width, height: size().height)
    }
    
    func onDragged(startInVideoRect: CGPoint, endInVideoRect: CGPoint) {
        self.transform.draggingOffset = CGSize(width: endInVideoRect.x - startInVideoRect.x,
                                               height: endInVideoRect.y - startInVideoRect.y)
    }
    
    func onDragEnded(startInVideoRect: CGPoint, endInVideoRect: CGPoint) {
        let transformOnDragStart = PenToolPathTransform()
        transformOnDragStart.copyValues(from: self.transform)
        transformOnDragStart.draggingOffset = .zero
        
        self.transform.start = self.transform.start + (endInVideoRect - startInVideoRect)
        self.transform.end = self.transform.end + (endInVideoRect - startInVideoRect)
        self.transform.draggingOffset = .zero
        
        pathHistory.addTransformUndoableStep(oldTransform: transformOnDragStart)
    }
    
    private func size() -> CGSize {
        return CGSize(width: abs(transform.end.x - transform.start.x),
                      height: abs(transform.end.y - transform.start.y))
    }
    private func opacity() -> Double { return Double(_drawnStyle.opacity) / 100 }
        
    var body: some View {
        // GeometryReaderを使うとなぜかframeの位置とサイズがバグる問題が解決するので使っておく
        // offsetとframeは親View（PenToolDrawnPath）で設定。選択時の表示や処理のため。
        GeometryReader { geometry in
            Path { path in
                path.addArc(center: CGPoint(x: 0.5, y: 0.5),
                            radius: 0.5,
                            startAngle: .degrees(0),
                            endAngle: .degrees(360),
                            clockwise: false,
                            transform: CGAffineTransform(scaleX: size().width, y: size().height))
            }
                .fill(_drawnStyle.color)
                .opacity(opacity())
//                .border(.red, width: 3)
        }
    }
}

struct CircleFillPath_Previews: PreviewProvider {
    static var previews: some View {
        EmptyView()
    }
}
