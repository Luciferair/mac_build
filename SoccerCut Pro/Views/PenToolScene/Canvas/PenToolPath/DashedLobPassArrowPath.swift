//
//  DashedLobPassArrowPath.swift
//  SoccerCut Pro

import SwiftUI

struct DashedLobPassArrowPath: View, PenToolPathProtocol {
    let type: PenToolType = .dashedLobPassArrow
    private let pathHistory: PenToolPathHistory
    @ObservedObject private var _drawnStyle = PenToolPathStyle()
    @ObservedObject private var transform = PenToolPathTransform()

    init() { pathHistory = PenToolModel.now.pathHistory }

    mutating func initialize(startInResolution: CGPoint, endInResolution: CGPoint) {
        self._drawnStyle.copyValues(from: PenToolModel.now.pathFactory.styleOf(type))
        self.transform.start = startInResolution
        self.transform.end = endInResolution
    }

    func drawnStyle() -> PenToolPathStyle { _drawnStyle }
    func applyStyle(_ newStyle: PenToolPathStyle) { _drawnStyle.copyValues(from: newStyle) }
    func drawnTransform() -> PenToolPathTransform { transform }
    func applyTransform(_ newTransform: PenToolPathTransform) { transform.copyValues(from: newTransform) }

    func offset() -> CGSize {
        CGSize(width: start().x + (start().x <= end().x ? .zero : end().x - start().x) - lineWidth()/2,
               height: start().y + (topPoint().y - start().y) - lineWidth()/2)
        + transform.draggingOffset
    }
    func frame() -> CGSize {
        CGSize(width: abs(start().x - end().x) + lineWidth(),
               height: max(start().y, end().y) - topPoint().y + lineWidth())
    }

    func onDragged(startInVideoRect: CGPoint, endInVideoRect: CGPoint) {
        transform.draggingOffset = CGSize(width: endInVideoRect.x - startInVideoRect.x,
                                          height: endInVideoRect.y - startInVideoRect.y)
    }
    func onDragEnded(startInVideoRect: CGPoint, endInVideoRect: CGPoint) {
        let old = PenToolPathTransform(); old.copyValues(from: transform); old.draggingOffset = .zero
        transform.start = transform.start + (endInVideoRect - startInVideoRect)
        transform.end   = transform.end   + (endInVideoRect - startInVideoRect)
        transform.draggingOffset = .zero
        pathHistory.addTransformUndoableStep(oldTransform: old)
    }

    private func start() -> CGPoint { transform.start }
    private func end()   -> CGPoint { transform.end }
    private func opacity() -> Double { Double(_drawnStyle.opacity) / 100 }
    private func lineWidth() -> CGFloat { CGFloat(_drawnStyle.lineWidth) }
    private func controlPointHeight() -> CGFloat { CGFloat(_drawnStyle.lineTopHeight * 3) }
    private func arrowheadSize() -> CGFloat { CGFloat(_drawnStyle.arrowheadSize) }

    private func controlPoint() -> CGPoint {
        CGPoint(x: (start().x + end().x) / 2,
                y: (start().y + end().y) / 2 - controlPointHeight())
    }
    private func topPoint() -> CGPoint {
        let cp = controlPoint()
        let ax = 2 * (start().x - 2*cp.x + end().x); let bx = 2 * (-start().x + cp.x)
        let ay = 2 * (start().y - 2*cp.y + end().y); let by = 2 * (-start().y + cp.y)
        let t: CGFloat = -(ax*bx + ay*by) / (ax*ax + ay*ay)
        return CGPoint(x: (1-t)*(1-t)*start().x + 2*(1-t)*t*cp.x + t*t*end().x,
                       y: (1-t)*(1-t)*start().y + 2*(1-t)*t*cp.y + t*t*end().y)
    }
    private func arrowheadAngle() -> Angle {
        let d = end() - controlPoint()
        let cos = (d.x) / sqrt(d.x*d.x + d.y*d.y)
        return Angle(degrees: acos(cos) * 180 / Double.pi)
    }
    private func lineDrawEnd() -> CGPoint {
        end() - CGPoint(x: arrowheadSize() * Darwin.cos(arrowheadAngle().radians),
                        y: arrowheadSize() * Darwin.sin(arrowheadAngle().radians))
    }

    var body: some View {
        GeometryReader { _ in
            ZStack {
                Path { path in
                    let vector = end() - start()
                    let lwo = CGPoint(x: lineWidth()/2, y: lineWidth()/2)
                    var offset = CGPoint(x: .zero, y: -(topPoint().y - start().y)) - start() + lwo
                    if vector.x < 0 { offset.x -= vector.x }
                    path.move(to: start() + offset)
                    path.addQuadCurve(to: lineDrawEnd() + offset, control: controlPoint() + offset)
                }
                .strokedPath(StrokeStyle(lineWidth: lineWidth(),
                                         dash: [CGFloat(_drawnStyle.dashLength), CGFloat(_drawnStyle.dashInterval)]))
                .foregroundColor(_drawnStyle.color)
                .opacity(opacity())

                Path { path in
                    let vector = end() - start()
                    let lwo = CGPoint(x: lineWidth()/2, y: lineWidth()/2)
                    var offset = CGPoint(x: .zero, y: -(topPoint().y - start().y)) - start() + lwo
                    if vector.x < 0 { offset.x -= vector.x }
                    let a90 = Angle(degrees: arrowheadAngle().degrees + 90)
                    let left  = lineDrawEnd() + offset + CGPoint(x: arrowheadSize()/2 * cos(a90.radians), y: arrowheadSize()/2 * sin(a90.radians))
                    let right = lineDrawEnd() + offset - CGPoint(x: arrowheadSize()/2 * cos(a90.radians), y: arrowheadSize()/2 * sin(a90.radians))
                    path.move(to: end() + offset); path.addLine(to: left)
                    path.addLine(to: right); path.addLine(to: end() + offset); path.closeSubpath()
                }
                .fill(_drawnStyle.color)
                .opacity(opacity())
            }
        }
    }
}
