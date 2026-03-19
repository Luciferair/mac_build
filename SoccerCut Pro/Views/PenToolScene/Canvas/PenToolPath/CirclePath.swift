//
//  CirclePath.swift
//  SoccerCut Pro
//
//  Created by Naoki Tanaka on 2023/08/06.
//

import SwiftUI

struct CirclePath: View, PenToolPathProtocol {
    let type: PenToolType = .circle
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
        return CGSize(width: transform.start.x - size().width/2,
                      height: transform.start.y - size().height/2)
               + transform.draggingOffset
    }
    func frame() -> CGSize { return size() }
    
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
    private func circleAngle() -> Angle { return Angle(degrees: Double(_drawnStyle.circleDegrees)) }
    private func startAngle() -> Angle { return Angle(degrees: -90 + (360 - circleAngle().degrees) / 2) }
        
    var body: some View {
        // GeometryReaderを使うとなぜかframeの位置とサイズがバグる問題が解決するので使っておく
        // offsetとframeは親View（PenToolDrawnPath）で設定。選択時の表示や処理のため。
        GeometryReader { geometry in
            Path { path in
                path.addArc(center: CGPoint(x: 0.5, y: 0.5),
                            radius: 0.5,
                            startAngle: startAngle(),
                            endAngle: startAngle() + circleAngle(),
                            clockwise: false,
                            transform: CGAffineTransform(scaleX: size().width, y: size().height))
            }
//                .stroke(color, lineWidth: lineWidth)
                .stroke(
                    AngularGradient(
                        gradient: Gradient(stops: [
                            .init(color: Color(red: _drawnStyle.color.r, green: _drawnStyle.color.g, blue: _drawnStyle.color.b, opacity: 0), location: 0.0),
                            .init(color: Color(red: _drawnStyle.color.r, green: _drawnStyle.color.g, blue: _drawnStyle.color.b, opacity: _drawnStyle.color.a), location: 0.08),
                            .init(color: Color(red: _drawnStyle.color.r, green: _drawnStyle.color.g, blue: _drawnStyle.color.b, opacity: _drawnStyle.color.a), location: 0.92),
                            .init(color: Color(red: _drawnStyle.color.r, green: _drawnStyle.color.g, blue: _drawnStyle.color.b, opacity: 0), location: 1.0)
                        ]),
                        center: .center,
                        startAngle: startAngle(),
                        endAngle: startAngle() + circleAngle()
                    ),
                    lineWidth: CGFloat(_drawnStyle.lineWidth)
                )
                .opacity(Double(_drawnStyle.opacity) / 100)
//                .border(.red, width: 3)
        }
    }
}

struct CirclePath_Previews: PreviewProvider {
    static var previews: some View {
        EmptyView()
    }
}
