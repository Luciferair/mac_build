//
//  TrianglePath.swift
//  SoccerCut Pro

import SwiftUI

struct TrianglePath: View, PenToolPathProtocol {
    let type: PenToolType = .triangle
    private let pathHistory: PenToolPathHistory
    @ObservedObject private var _drawnStyle = PenToolPathStyle()
    @ObservedObject private var transform = PenToolPathTransform()

    init() { pathHistory = PenToolModel.now.pathHistory }

    mutating func initialize(startInResolution: CGPoint, endInResolution: CGPoint) {
        _drawnStyle.copyValues(from: PenToolModel.now.pathFactory.styleOf(type))
        transform.start = startInResolution; transform.end = endInResolution
    }

    func drawnStyle() -> PenToolPathStyle { _drawnStyle }
    func applyStyle(_ s: PenToolPathStyle) { _drawnStyle.copyValues(from: s) }
    func drawnTransform() -> PenToolPathTransform { transform }
    func applyTransform(_ t: PenToolPathTransform) { transform.copyValues(from: t) }

    func offset() -> CGSize {
        CGSize(width: min(transform.start.x, transform.end.x) - lineWidth()/2,
               height: min(transform.start.y, transform.end.y) - lineWidth()/2)
        + transform.draggingOffset
    }
    func frame() -> CGSize {
        CGSize(width: abs(transform.start.x - transform.end.x) + lineWidth(),
               height: abs(transform.start.y - transform.end.y) + lineWidth())
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

    private func lineWidth() -> CGFloat { CGFloat(_drawnStyle.lineWidth) }
    private func opacity() -> Double { Double(_drawnStyle.opacity) / 100 }

    var body: some View {
        GeometryReader { _ in
            let lw = lineWidth()
            let w = abs(transform.end.x - transform.start.x)
            let h = abs(transform.end.y - transform.start.y)
            Path { path in
                // isosceles triangle: apex at top-center, base at bottom
                path.move(to: CGPoint(x: w/2 + lw/2, y: lw/2))
                path.addLine(to: CGPoint(x: lw/2, y: h + lw/2))
                path.addLine(to: CGPoint(x: w + lw/2, y: h + lw/2))
                path.closeSubpath()
            }
            .stroke(lineWidth: lw)
            .foregroundColor(_drawnStyle.color)
            .opacity(opacity())
        }
    }
}

struct TriangleFillPath: View, PenToolPathProtocol {
    let type: PenToolType = .triangleFill
    private let pathHistory: PenToolPathHistory
    @ObservedObject private var _drawnStyle = PenToolPathStyle()
    @ObservedObject private var transform = PenToolPathTransform()

    init() { pathHistory = PenToolModel.now.pathHistory }

    mutating func initialize(startInResolution: CGPoint, endInResolution: CGPoint) {
        _drawnStyle.copyValues(from: PenToolModel.now.pathFactory.styleOf(type))
        transform.start = startInResolution; transform.end = endInResolution
    }

    func drawnStyle() -> PenToolPathStyle { _drawnStyle }
    func applyStyle(_ s: PenToolPathStyle) { _drawnStyle.copyValues(from: s) }
    func drawnTransform() -> PenToolPathTransform { transform }
    func applyTransform(_ t: PenToolPathTransform) { transform.copyValues(from: t) }

    func offset() -> CGSize {
        CGSize(width: min(transform.start.x, transform.end.x),
               height: min(transform.start.y, transform.end.y))
        + transform.draggingOffset
    }
    func frame() -> CGSize {
        CGSize(width: abs(transform.start.x - transform.end.x),
               height: abs(transform.start.y - transform.end.y))
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

    private func opacity() -> Double { Double(_drawnStyle.opacity) / 100 }

    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width; let h = geo.size.height
            Path { path in
                path.move(to: CGPoint(x: w/2, y: 0))
                path.addLine(to: CGPoint(x: 0, y: h))
                path.addLine(to: CGPoint(x: w, y: h))
                path.closeSubpath()
            }
            .fill(_drawnStyle.color)
            .opacity(opacity())
        }
    }
}
