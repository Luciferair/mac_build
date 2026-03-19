//
//  ConnectedCirclesPath.swift
//  SoccerCut Pro

import SwiftUI

class ConnectedCirclesNodes: ObservableObject {
    struct Node {
        var center: CGPoint
        var radius: CGFloat
        var gapCenterDegrees: Double
    }
    @Published var nodes: [Node] = []
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

    // start = circle center, end = radius point
    func initialize(startInResolution: CGPoint, endInResolution: CGPoint) {
        self._drawnStyle.copyValues(from: PenToolModel.now.pathFactory.styleOf(type))
        self.transform.start = startInResolution
        self.transform.end = endInResolution
        let r = (endInResolution - startInResolution).length
        nodes.nodes = [ConnectedCirclesNodes.Node(center: startInResolution,
                                                  radius: max(r, 5),
                                                  gapCenterDegrees: 270)]
        nodes.selectedNodeIndex = 0
    }

    /// Append a confirmed node
    func appendNode(_ center: CGPoint, radius: CGFloat) {
        let defaultAngle = nodes.nodes.last?.gapCenterDegrees ?? 270
        nodes.nodes.append(ConnectedCirclesNodes.Node(center: center,
                                                      radius: max(radius, 5),
                                                      gapCenterDegrees: defaultAngle))
        nodes.selectedNodeIndex = nodes.nodes.count - 1
    }

    /// Update the last node during live drag preview
    func updateLastNode(center: CGPoint, radius: CGFloat) {
        guard !nodes.nodes.isEmpty else { return }
        nodes.nodes[nodes.nodes.count - 1].center = center
        nodes.nodes[nodes.nodes.count - 1].radius = max(radius, 5)
    }

    func selectNearestNode(at pointInResolution: CGPoint, hitRadius: CGFloat = 40) -> Bool {
        var bestIndex: Int? = nil
        var bestDistance: CGFloat = .greatestFiniteMagnitude
        for i in 0..<nodes.nodes.count {
            let d = hypot(nodes.nodes[i].center.x - pointInResolution.x,
                          nodes.nodes[i].center.y - pointInResolution.y)
            let threshold = max(hitRadius, nodes.nodes[i].radius)
            if d <= threshold && d < bestDistance {
                bestDistance = d
                bestIndex = i
            }
        }
        nodes.selectedNodeIndex = bestIndex
        return bestIndex != nil
    }

    func clearSelectedNode() { nodes.selectedNodeIndex = nil }

    func selectedNodeAngleDegrees() -> Int32? {
        guard let i = nodes.selectedNodeIndex, i < nodes.nodes.count else { return nil }
        return Int32(nodes.nodes[i].gapCenterDegrees.rounded())
    }

    func setSelectedNodeAngleDegrees(_ newValue: Int32) {
        guard let i = nodes.selectedNodeIndex, i < nodes.nodes.count else { return }
        let normalized = ((Double(newValue).truncatingRemainder(dividingBy: 360)) + 360)
            .truncatingRemainder(dividingBy: 360)
        nodes.nodes[i].gapCenterDegrees = normalized
    }

    func drawnStyle() -> PenToolPathStyle { _drawnStyle }
    func applyStyle(_ newStyle: PenToolPathStyle) { _drawnStyle.copyValues(from: newStyle) }
    func drawnTransform() -> PenToolPathTransform { transform }
    func applyTransform(_ newTransform: PenToolPathTransform) { transform.copyValues(from: newTransform) }

    func offset() -> CGSize {
        guard !nodes.nodes.isEmpty else { return .zero }
        // Bounding box: each node occupies [center - radius, center + radius]
        let minX = nodes.nodes.map { $0.center.x - $0.radius }.min()!
        let minY = nodes.nodes.map { $0.center.y - $0.radius }.min()!
        return CGSize(width: minX, height: minY) + nodes.draggingOffset
    }

    func frame() -> CGSize {
        guard !nodes.nodes.isEmpty else { return CGSize(width: 1, height: 1) }
        let minX = nodes.nodes.map { $0.center.x - $0.radius }.min()!
        let minY = nodes.nodes.map { $0.center.y - $0.radius }.min()!
        let maxX = nodes.nodes.map { $0.center.x + $0.radius }.max()!
        let maxY = nodes.nodes.map { $0.center.y + $0.radius }.max()!
        // Add strokeLW/2 padding so the stroke isn't clipped at the edge
        let pad = CGFloat(_drawnStyle.lineWidth) / 2 + 2
        return CGSize(width: max(maxX - minX + pad * 2, 1),
                      height: max(maxY - minY + pad * 2, 1))
    }

    func onDragged(startInVideoRect: CGPoint, endInVideoRect: CGPoint) {
        nodes.draggingOffset = CGSize(width: endInVideoRect.x - startInVideoRect.x,
                                     height: endInVideoRect.y - startInVideoRect.y)
    }

    func onDragEnded(startInVideoRect: CGPoint, endInVideoRect: CGPoint) {
        if abs(endInVideoRect.x - startInVideoRect.x) < 0.5 &&
           abs(endInVideoRect.y - startInVideoRect.y) < 0.5 {
            nodes.draggingOffset = .zero
            return
        }
        let old = PenToolPathTransform()
        old.copyValues(from: transform)
        old.draggingOffset = .zero
        let delta = endInVideoRect - startInVideoRect
        for i in 0..<nodes.nodes.count {
            nodes.nodes[i].center = CGPoint(x: nodes.nodes[i].center.x + delta.x,
                                            y: nodes.nodes[i].center.y + delta.y)
        }
        nodes.draggingOffset = .zero
        pathHistory.addTransformUndoableStep(oldTransform: old)
    }

    private func lineEndpoints(from a: ConnectedCirclesNodes.Node,
                                to b: ConnectedCirclesNodes.Node,
                                margin: CGFloat = 2) -> (CGPoint, CGPoint)? {
        let dx = b.center.x - a.center.x
        let dy = b.center.y - a.center.y
        let distance = sqrt(dx * dx + dy * dy)
        if distance < 0.001 { return nil }
        let ux = dx / distance
        let uy = dy / distance
        let startInset = min(a.radius + margin, distance / 2)
        let endInset   = min(b.radius + margin, distance / 2)
        return (CGPoint(x: a.center.x + ux * startInset, y: a.center.y + uy * startInset),
                CGPoint(x: b.center.x - ux * endInset,   y: b.center.y - uy * endInset))
    }

    var body: some View {
        GeometryReader { _ in
            let ns = nodes.nodes
            guard !ns.isEmpty else { return AnyView(EmptyView()) }

            let off = offset()
            let frameSize = frame()
            let strokeLW = CGFloat(_drawnStyle.lineWidth)
            let connLW   = CGFloat(max(_drawnStyle.connectorLineWidth, 1))
            let baseColor = Color(red: _drawnStyle.color.r,
                                  green: _drawnStyle.color.g,
                                  blue: _drawnStyle.color.b,
                                  opacity: _drawnStyle.color.a)
            let circleAngleDeg = Double(_drawnStyle.circleDegrees)

            return AnyView(
                ZStack {
                    // Connecting lines
                    if ns.count >= 2 {
                        ForEach(0..<ns.count - 1, id: \.self) { i in
                            if let ep = lineEndpoints(from: ns[i], to: ns[i + 1]) {
                                Path { path in
                                    path.move(to: CGPoint(x: ep.0.x - off.width,
                                                          y: ep.0.y - off.height))
                                    path.addLine(to: CGPoint(x: ep.1.x - off.width,
                                                             y: ep.1.y - off.height))
                                }
                                .stroke(baseColor, lineWidth: connLW)
                            }
                        }
                    }

                    // Circles — gradient fade (same style as CirclePath)
                    ForEach(0..<ns.count, id: \.self) { i in
                        let node = ns[i]
                        let lx = node.center.x - off.width
                        let ly = node.center.y - off.height
                        let r  = node.radius
                        let gapDeg    = 360 - circleAngleDeg
                        let arcStart  = Angle(degrees: node.gapCenterDegrees + gapDeg / 2)
                        let arcEnd    = arcStart + Angle(degrees: circleAngleDeg)

                        ZStack {
                            Path { path in
                                path.addArc(center: CGPoint(x: lx, y: ly),
                                            radius: r,
                                            startAngle: arcStart,
                                            endAngle: arcEnd,
                                            clockwise: false)
                            }
                            .stroke(
                                AngularGradient(
                                    gradient: Gradient(stops: [
                                        .init(color: baseColor.opacity(0), location: 0.0),
                                        .init(color: baseColor, location: 0.08),
                                        .init(color: baseColor, location: 0.92),
                                        .init(color: baseColor.opacity(0), location: 1.0)
                                    ]),
                                    center: UnitPoint(x: lx / max(frameSize.width, 1),
                                                      y: ly / max(frameSize.height, 1)),
                                    startAngle: arcStart,
                                    endAngle: arcEnd
                                ),
                                lineWidth: strokeLW
                            )

                            if nodes.selectedNodeIndex == i {
                                Circle()
                                    .stroke(Color.white, lineWidth: max(2, strokeLW / 2))
                                    .frame(width: r * 2 + 8, height: r * 2 + 8)
                                    .position(x: lx, y: ly)
                            }
                        }
                    }
                }
                .opacity(Double(_drawnStyle.opacity) / 100)
            )
        }
    }
}
