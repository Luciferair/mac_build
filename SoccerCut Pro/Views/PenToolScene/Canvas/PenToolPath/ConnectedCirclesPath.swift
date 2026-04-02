//
//  ConnectedCirclesPath.swift
//  SoccerCut Pro

import SwiftUI

class ConnectedCirclesNodes: ObservableObject {
    @Published var points: [CGPoint] = []
    @Published var nodeGapCenterDegrees: [Double] = []
    @Published var selectedNodeIndex: Int? = nil
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
        nodes.points = [startInResolution]
        nodes.nodeGapCenterDegrees = [270]
        nodes.selectedNodeIndex = 0
    }

    /// Called by the drawer to start a new segment from the last confirmed node
    func appendNode(_ point: CGPoint) {
        nodes.points.append(point)
        nodes.nodeGapCenterDegrees.append(nodes.nodeGapCenterDegrees.last ?? 270)
        nodes.selectedNodeIndex = nodes.points.count - 1
    }

    /// Called by the drawer to update the preview of the in-progress segment
    func updateLastNode(_ point: CGPoint) {
        guard !nodes.points.isEmpty else { return }
        nodes.points[nodes.points.count - 1] = point
    }

    func selectNearestNode(at pointInResolution: CGPoint, hitRadius: CGFloat = 40) -> Bool {
        var bestIndex: Int? = nil
        var bestDistance: CGFloat = .greatestFiniteMagnitude
        for i in 0..<nodes.points.count {
            let d = hypot(nodes.points[i].x - pointInResolution.x, nodes.points[i].y - pointInResolution.y)
            if d <= hitRadius && d < bestDistance {
                bestDistance = d
                bestIndex = i
            }
        }
        nodes.selectedNodeIndex = bestIndex
        return bestIndex != nil
    }

    func clearSelectedNode() {
        nodes.selectedNodeIndex = nil
    }

    func selectedNodeAngleDegrees() -> Int32? {
        guard let i = nodes.selectedNodeIndex, i >= 0, i < nodes.nodeGapCenterDegrees.count else { return nil }
        return Int32(nodes.nodeGapCenterDegrees[i].rounded())
    }

    func setSelectedNodeAngleDegrees(_ newValue: Int32) {
        guard let i = nodes.selectedNodeIndex, i >= 0, i < nodes.nodeGapCenterDegrees.count else { return }
        let normalized = ((Double(newValue).truncatingRemainder(dividingBy: 360)) + 360).truncatingRemainder(dividingBy: 360)
        nodes.nodeGapCenterDegrees[i] = normalized
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
        if abs(endInVideoRect.x - startInVideoRect.x) < 0.5 && abs(endInVideoRect.y - startInVideoRect.y) < 0.5 {
            nodes.draggingOffset = .zero
            return
        }
        let old = PenToolPathTransform()
        old.copyValues(from: transform)
        old.draggingOffset = .zero
        let delta = endInVideoRect - startInVideoRect
        nodes.points = nodes.points.map { CGPoint(x: $0.x + delta.x, y: $0.y + delta.y) }
        nodes.draggingOffset = .zero
        pathHistory.addTransformUndoableStep(oldTransform: old)
    }

    private func markerCircleAngle() -> Angle {
        Angle(degrees: Double(_drawnStyle.circleDegrees))
    }

    private func markerStartAngle(gapCenterDegrees: Double) -> Angle {
        let gapDegrees = 360 - markerCircleAngle().degrees
        return Angle(degrees: gapCenterDegrees + gapDegrees / 2)
    }

    private func lineEndpoints(from a: CGPoint, to b: CGPoint, radius: CGFloat, margin: CGFloat) -> (CGPoint, CGPoint)? {
        let dx = b.x - a.x
        let dy = b.y - a.y
        let distance = sqrt(dx * dx + dy * dy)
        if distance < 0.001 { return nil }

        let ux = dx / distance
        let uy = dy / distance
        let inset = min(radius + margin, distance / 2)

        let start = CGPoint(x: a.x + ux * inset, y: a.y + uy * inset)
        let end = CGPoint(x: b.x - ux * inset, y: b.y - uy * inset)
        return (start, end)
    }

    var body: some View {
        GeometryReader { _ in
            let pts = nodes.points
            guard !pts.isEmpty else { return AnyView(EmptyView()) }

            let off = offset()
            let lw = CGFloat(_drawnStyle.lineWidth)
            let color = Color(red: _drawnStyle.color.r,
                              green: _drawnStyle.color.g,
                              blue: _drawnStyle.color.b,
                              opacity: _drawnStyle.color.a)

            // Circle radius: fixed in resolution space, scaled by parent scaleEffect
            let r: CGFloat = 30
            let lineMargin: CGFloat = 2

            return AnyView(
                ZStack {
                    // Lines between consecutive nodes
                    if pts.count >= 2 {
                        ForEach(0..<pts.count - 1, id: \.self) { i in
                            let a = pts[i]
                            let b = pts[i + 1]
                            if let endpoints = lineEndpoints(from: a, to: b, radius: r, margin: lineMargin) {
                                Path { path in
                                    path.move(to: CGPoint(x: endpoints.0.x - off.width, y: endpoints.0.y - off.height))
                                    path.addLine(to: CGPoint(x: endpoints.1.x - off.width, y: endpoints.1.y - off.height))
                                }
                                .stroke(color, lineWidth: lw)
                            }
                        }
                    }
                    // Circles at each node
                    ForEach(0..<pts.count, id: \.self) { i in
                        let p = pts[i]
                        let lx = p.x - off.width
                        let ly = p.y - off.height
                        let gapCenter = i < nodes.nodeGapCenterDegrees.count ? nodes.nodeGapCenterDegrees[i] : 270
                        Path { path in
                            path.addArc(center: CGPoint(x: lx, y: ly),
                                        radius: r,
                                        startAngle: markerStartAngle(gapCenterDegrees: gapCenter),
                                        endAngle: markerStartAngle(gapCenterDegrees: gapCenter) + markerCircleAngle(),
                                        clockwise: false)
                        }
                        .stroke(color, lineWidth: lw)

                        if nodes.selectedNodeIndex == i {
                            Circle()
                                .stroke(Color.white, lineWidth: max(2, lw / 2))
                                .frame(width: r * 2 + 8, height: r * 2 + 8)
                                .position(x: lx, y: ly)
                        }
                    }
                }
                .opacity(Double(_drawnStyle.opacity) / 100)
            )
        }
    }
}
