//
//  LobPassArrowPath.swift
//  SoccerCut Pro
//
//  Created by Naoki Tanaka on 2023/10/31.
//

import SwiftUI

struct LobPassArrowPath: View, PenToolPathProtocol {
    let type: PenToolType = .lobPassArrow
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
        return CGSize(width: start().x + (start().x <= end().x ? .zero : end().x - start().x) - lineWidth()/2,
                      height: start().y + (topPoint().y - start().y) - lineWidth()/2)
               + transform.draggingOffset
    }
    func frame() -> CGSize {
        return CGSize(width: abs(start().x - end().x) + lineWidth(),
                      height: max(start().y, end().y) - topPoint().y + lineWidth())
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
    
    private func start() -> CGPoint { return transform.start }
    private func end() -> CGPoint { return transform.end }
    private func opacity() -> Double { return Double(_drawnStyle.opacity) / 100 }
    private func lineWidth() -> CGFloat { return CGFloat(_drawnStyle.lineWidth) }
    private func controlPointHeight() -> CGFloat { return CGFloat(_drawnStyle.lineTopHeight * 3) }
    private func arrowheadSize() -> CGFloat { return CGFloat(_drawnStyle.arrowheadSize) }
    
    private func controlPoint() -> CGPoint {
        let start = transform.start
        let end = transform.end
        return CGPoint(x: (start.x + end.x) / 2, y: (start.y + end.y) / 2 - controlPointHeight())
    }
    
    private func topPoint() -> CGPoint {
        let ctrlPoint: CGPoint = controlPoint()
        // ベジェ曲線において曲率半径が極小値になる変数tを求める
        let ax: CGFloat = 2 * (start().x - 2*ctrlPoint.x + end().x)
        let bx: CGFloat = 2 * (-start().x + ctrlPoint.x)
        let ay: CGFloat = 2 * (start().y - 2*ctrlPoint.y + end().y)
        let by: CGFloat = 2 * (-start().y + ctrlPoint.y)
        let t: CGFloat = -(ax*bx + ay*by) / (ax*ax + ay*ay)
        
        // ベジェ曲線のてっぺんの座標を求める
        return CGPoint(x: (1-t)*(1-t)*start().x + 2*(1-t)*t*ctrlPoint.x + t*t*end().x,
                       y: (1-t)*(1-t)*start().y + 2*(1-t)*t*ctrlPoint.y + t*t*end().y)
    }
    
    private func arrowheadAngle() -> Angle {
        let directionToEndVec = end() - controlPoint()
        let horizonUnitVec = CGPoint(x: 1, y: 0)
        let cosTheta = (horizonUnitVec.x * directionToEndVec.x + horizonUnitVec.y * directionToEndVec.y)
                        / (sqrt(pow(horizonUnitVec.x, 2) + pow(horizonUnitVec.y, 2)) * sqrt(pow(directionToEndVec.x, 2) + pow(directionToEndVec.y, 2)))
        return Angle(degrees: acos(cosTheta) * 180 / Double.pi)
    }
    
    private func lineDrawEnd() -> CGPoint {
        // 矢尻の根元
        return end() - CGPoint(x: CGFloat(arrowheadSize()) * cos(arrowheadAngle().radians),
                               y: CGFloat(arrowheadSize()) * sin(arrowheadAngle().radians))
    }
    
    var body: some View {
        // GeometryReaderを使うとなぜかframeの位置とサイズがバグる問題が解決するので使っておく
        // offsetとframeは親View（PenToolDrawnPath）で設定。選択時の表示や処理のため。
        GeometryReader { _ in
            ZStack {
                Path { path in
                    // 最初からドラッグ位置にPathを置こうとするとframeがずれるので、
                    // まずは画面左端と上端に線が接する状態（frameの原点？）で描いて、bodyで移動させる。
                    let vector = end() - start()
                    
                    let lineWidthOffset = CGPoint(x: lineWidth()/2, y: lineWidth()/2)
                    var offset = CGPoint(x: .zero, y: -(topPoint().y - start().y)) - start() + lineWidthOffset
                    if vector.x < 0 { offset.x -= vector.x }
                    
                    path.move(to: start() + offset)
                    path.addQuadCurve(to: lineDrawEnd() + offset,
                                      control: controlPoint() + offset)
                }
                    .stroke(lineWidth: lineWidth())
                    .foregroundColor(_drawnStyle.color)
                    .opacity(opacity())
                
                Path { path in
                    let vector = end() - start()
                    
                    let lineWidthOffset = CGPoint(x: lineWidth()/2, y: lineWidth()/2)
                    var offset = CGPoint(x: .zero, y: -(topPoint().y - start().y)) - start() + lineWidthOffset
                    if vector.x < 0 { offset.x -= vector.x }
                    
                    let arrowheadAnglePlus90 = Angle(degrees: arrowheadAngle().degrees + 90)
                    
                    let arrowheadLeft = lineDrawEnd() + offset + CGPoint(x: arrowheadSize() / 2 * cos(arrowheadAnglePlus90.radians),
                                                                         y: arrowheadSize() / 2 * sin(arrowheadAnglePlus90.radians))
                    let arrowheadRight = lineDrawEnd() + offset - CGPoint(x: arrowheadSize() / 2 * cos(arrowheadAnglePlus90.radians),
                                                                          y: arrowheadSize() / 2 * sin(arrowheadAnglePlus90.radians))
                    
                    path.move(to: end() + offset)
                    path.addLine(to: arrowheadLeft)
                    path.addLine(to: arrowheadRight)
                    path.addLine(to: end() + offset)
                    path.closeSubpath()
                }
                    .fill(_drawnStyle.color)
                    .opacity(opacity())
            }
//            .border(.red, width: 3)
        }
    }
}
    

struct LobPassArrowPath_Previews: PreviewProvider {
    static var previews: some View {
        EmptyView()
    }
}
