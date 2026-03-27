//
//  ConnectedCirclesPath.swift
//  SoccerCut Pro

import SwiftUI

class ConnectedCirclesNodes: ObservableObject {
    @Published var points: [CGPoint] = []
    @Published var draggingOffset: CGSize = .zero
}

struct ConnectedCirclesPath: View, PenToolPathProtocol {
    let type: PenToolType = .connectedCircles
    private let pathHistory: PenToolPathHistory
    @ObservedObject private var _drawnStyle = PenToolPathStyle()
    @ObservedObject private var transform = PenToolPathTransform()
    @ObservedObject private(set) var nodes = ConnectedCirclesNodes()

    init() {
        pathHistory = PenToolModel.now.pathHistory
    }

    func initialize(startInResolution: CGPoint, endInResolution: CGPoint) {
        self._drawnStyle.copyValues(from: PenToolModel.now.pathFactory.styleOf(type))
        self.transform.start = startInResolution
        self.transform.end = endInResolution
        nodes.points = [startInResolution, endInResolution]
    }

    /// Called by the drawer to start a new segment from the last confirmed node
    func appendNode(_ point: CGPoint) {
        nodes.points.append(point)
    }

    /// Called by the drawer to update the preview of the in-progress segment
    func updateLastNode(_ point: CGPoint) {
        guard !nodes.points.isEmpty else { return }
        nodes.points[nodes.points.count - 1] = point
    }

    func drawnStyle() -> PenToolPathStyle { _drawnStyle }
    func applyStyle(_ newStyle: PenToolPathStyle) { _drawnStyle.copyValues(from: newStyle) }
    func drawnTransform() -> PenToolPathTransform { transform }
    func applyTransform(_ newTransform: PenToolPathTransform) { transform.copyValues(from: newTransform) }

    // Bounding box over all nodes + dragging offset
    func offset() -> CGSize {
        guard !nodes.points.isEmpty else { return .zero }
        let minX = nodes.points.map(\.x).min()!
        let minY = nodes.points.map(\.y).min()!
        return CGSize(width: minX, height: minY) + nodes.draggingOffset
    }

    func frame() -> CGSize {
        guard nodes.points.count >= 2 else { return CGSize(width: 1, height: 1) }
        let minX = nodes.points.map(\.x).min()!
        let minY = nodes.points.map(\.y).min()!
        let maxX = nodes.points.map(\.x).max()!
        let maxY = nodes.points.map(\.y).max()!
        return CGSize(width: max(maxX - minX, 1), height: max(maxY - minY, 1))
    }

    func onDragged(startInVideoRect: CGPoint, endInVideoRect: CGPoint) {
        nodes.draggingOffset = CGSize(width: endInVideoRect.x - startInVideoRect.x,
                                     height: endInVideoRect.y - startInVideoRect.y)
    }

    func onDragEnded(startInVideoRect: CGPoint, endInVideoRect: CGPoint) {
        let old = PenToolPathTransform()
        old.copyValues(from: transform)
        old.draggingOffset = .zero
        let delta = endInVideoRect - startInVideoRect
        nodes.points = nodes.points.map { CGPoint(x: $0.x + delta.x, y: $0.y + delta.y) }
        nodes.draggingOffset = .zero
        pathHistory.addTransformUndoableStep(oldTransform: old)
    }

    var body: some View {
        GeometryReader { _ in
            let pts = nodes.points
            guard pts.count >= 2 else { return AnyView(EmptyView()) }

            let off = offset()
            let lw = CGFloat(_drawnStyle.lineWidth)
            let color = Color(red: _drawnStyle.color.r,
                              green: _drawnStyle.color.g,
                              blue: _drawnStyle.color.b,
                              opacity: _drawnStyle.color.a)

            // Circle radius: fixed in resolution space, scaled by parent scaleEffect
            let r: CGFloat = 30

            return AnyView(
                ZStack {
                    // Lines between consecutive nodes
                    ForEach(0..<pts.count - 1, id: \.self) { i in
                        let a = pts[i]
                        let b = pts[i + 1]
                        Path { path in
                            path.move(to: CGPoint(x: a.x - off.width, y: a.y - off.height))
                            path.addLine(to: CGPoint(x: b.x - off.width, y: b.y - off.height))
                        }
                        .stroke(color, lineWidth: lw)
                    }
                    // Circles at each node
                    ForEach(0..<pts.count, id: \.self) { i in
                        let p = pts[i]
                        let lx = p.x - off.width
                        let ly = p.y - off.height
                        Path { path in
                            path.addEllipse(in: CGRect(x: lx - r, y: ly - r, width: r * 2, height: r * 2))
                        }
                        .stroke(color, lineWidth: lw)
                    }
                }
                .opacity(Double(_drawnStyle.opacity) / 100)
            )
        }
    }
}
