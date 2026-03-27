//
//  ArrowPath.swift
//  SoccerCut Pro
//
//  Created by Naoki Tanaka on 2023/07/31.
//

import SwiftUI

struct ArrowPath: View, PenToolPathProtocol {
    let type: PenToolType = .arrow
    private let pathHistory: PenToolPathHistory
    @ObservedObject private(set) var _drawnStyle = PenToolPathStyle()
    @ObservedObject private(set) var transform = PenToolPathTransform()
        
    init() {
        pathHistory = PenToolModel.now.pathHistory
    }
    
    mutating func initialize(startInResolution: CGPoint, endInResolution: CGPoint) {
        self._drawnStyle.copyValues(from: PenToolModel.now.pathFactory.styleOf(type))
        
        self.transform.start = startInResolution
        self.transform.end = endInResolution
    }
    
    func drawnStyle() -> PenToolPathStyle { return _drawnStyle }
    func applyStyle(_ newStyle: PenToolPathStyle) { _drawnStyle.copyValues(from: newStyle) }
    func drawnTransform() -> PenToolPathTransform { return transform }
    func applyTransform(_ newTransform: PenToolPathTransform) { transform.copyValues(from: newTransform) }
    
    // 真横や真縦に線を引くとwidthやheightが0になりクリックできる範囲が無くなるので、frameに線の太さを考慮できるようにする。
    func offset() -> CGSize {
        return CGSize(width: min(transform.start.x, transform.end.x) - lineWidth()/2,
                      height: min(transform.start.y, transform.end.y) - lineWidth()/2)
               + transform.draggingOffset
    }
    func frame() -> CGSize { 
        return CGSize(width: abs(transform.start.x - transform.end.x) + lineWidth(),
                      height: abs(transform.start.y - transform.end.y) + lineWidth())
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
    
    private func opacity() -> Double { return Double(_drawnStyle.opacity) / 100 }
    private func lineWidth() -> CGFloat { return CGFloat(_drawnStyle.lineWidth) }
    private func arrowheadSize() -> CGFloat { return CGFloat(_drawnStyle.arrowheadSize) }
            
    var body: some View {
        // GeometryReaderを使うとなぜかframeの位置とサイズがバグる問題が解決するので使っておく
        // offsetとframeは親View（PenToolDrawnPath）で設定。選択時の表示や処理のため。
        GeometryReader { _ in
            ZStack {
                Path { path in
                    // 最初からドラッグ位置にPathを置こうとするとframeがずれるので、
                    // まずは画面左端と上端に線が接する状態（frameの原点？）で描いて、bodyで移動させる。
                    let vector = transform.end - transform.start
                    let vecLineEnd = CGPoint(x: vector.unit.x * (vector.length - arrowheadSize()),
                                             y: vector.unit.y * (vector.length - arrowheadSize()))
                    let lineWidthOffset = CGPoint(x: lineWidth()/2, y: lineWidth()/2)
                    if 0 <= vector.x && 0 <= vector.y {
                        path.move(to: lineWidthOffset)
                        path.addLine(to: vecLineEnd + lineWidthOffset)
                    } else if 0 <= vector.x && vector.y < 0 {
                        path.move(to: CGPoint(x: .zero, y: -vector.y) + lineWidthOffset)
                        path.addLine(to: CGPoint(x: vecLineEnd.x, y: -vector.y + vecLineEnd.y) + lineWidthOffset)
                    } else if vector.x < 0 && 0 <= vector.y {
                        path.move(to: CGPoint(x: -vector.x, y: .zero) + lineWidthOffset)
                        path.addLine(to: CGPoint(x: -vector.x + vecLineEnd.x, y: vecLineEnd.y) + lineWidthOffset)
                    } else {
                        path.move(to: CGPoint(x: -vector.x, y: -vector.y) + lineWidthOffset)
                        path.addLine(to: CGPoint(x: -vector.x + vecLineEnd.x, y: -vector.y + vecLineEnd.y) + lineWidthOffset)
                    }
                }
                    .stroke(lineWidth: lineWidth())
                    .foregroundColor(_drawnStyle.color)
                    .opacity(opacity())
                
                Path { path in
                    let vector = transform.end - transform.start
                    var arrowheadTop: CGPoint
                    if 0 <= vector.x && 0 <= vector.y {
                        arrowheadTop = vector
                    } else if 0 <= vector.x && vector.y < 0 {
                        arrowheadTop = CGPoint(x: vector.x, y: .zero)
                    } else if 0 > vector.x && 0 <= vector.y {
                        arrowheadTop = CGPoint(x: .zero, y: vector.y)
                    } else {
                        arrowheadTop = .zero
                    }
                    let arrowheadLeft = CGPoint(x: arrowheadTop.x - vector.unit.x * arrowheadSize() - vector.unit.y * arrowheadSize()/2,
                                                y: arrowheadTop.y + vector.unit.x * arrowheadSize()/2 - vector.unit.y * arrowheadSize())
                    let arrowheadRight = CGPoint(x: arrowheadTop.x - vector.unit.x * arrowheadSize() + vector.unit.y * arrowheadSize()/2,
                                                 y: arrowheadTop.y - vector.unit.x * arrowheadSize()/2 - vector.unit.y * arrowheadSize())

                    let lineWidthOffset = CGPoint(x: lineWidth()/2, y: lineWidth()/2)
                    path.move(to: arrowheadTop + lineWidthOffset)
                    path.addLine(to: arrowheadLeft + lineWidthOffset)
                    path.addLine(to: arrowheadRight + lineWidthOffset)
                    path.addLine(to: arrowheadTop + lineWidthOffset)
                    path.closeSubpath()
                }
                    .fill(_drawnStyle.color)
                    .opacity(opacity())
            }
//            .border(.red, width: 3)
        }
    }
}
    

struct ArrowPath_Previews: PreviewProvider {
    static var previews: some View {
        EmptyView()
    }
}
