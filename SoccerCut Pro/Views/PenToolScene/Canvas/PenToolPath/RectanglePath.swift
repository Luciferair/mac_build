//
//  RectanglePath.swift
//  SoccerCut Pro

import SwiftUI

struct RectanglePath: View, PenToolPathProtocol {
    let type: PenToolType = .rectangle
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
                path.addRect(CGRect(x: lw/2, y: lw/2, width: w, height: h))
            }
            .stroke(lineWidth: lw)
            .foregroundColor(_drawnStyle.color)
            .opacity(opacity())
        }
    }
}

struct RectangleFillPath: View, PenToolPathProtocol {
    let type: PenToolType = .rectangleFill
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
            Rectangle()
                .fill(_drawnStyle.color)
                .opacity(opacity())
                .frame(width: geo.size.width, height: geo.size.height)
        }
    }
}
