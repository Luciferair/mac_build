//
//  PenToolPathFactory.swift
//  SoccerCut Pro
//
//  Created by Naoki Tanaka on 2023/08/05.
//

import Cocoa
import SwiftUI

class PenToolPathFactory: ObservableObject {
    @Published private(set) var currentType: PenToolType = .arrow
    private let drawers: Dictionary<PenToolType, PenToolPathDrawerProtocol> = [
        .arrow: ArrowPathDrawer() as any PenToolPathDrawerProtocol,
        .lobPassArrow: LobPassArrowPathDrawer() as any PenToolPathDrawerProtocol,
        .dashedArrow: DashedArrowPathDrawer() as any PenToolPathDrawerProtocol,
        .dashedLobPassArrow: DashedLobPassArrowPathDrawer() as any PenToolPathDrawerProtocol,
        .circle: CirclePathDrawer() as any PenToolPathDrawerProtocol,
        .circleFill: CircleFillPathDrawer() as any PenToolPathDrawerProtocol,
        .triangle: TrianglePathDrawer() as any PenToolPathDrawerProtocol,
        .triangleFill: TriangleFillPathDrawer() as any PenToolPathDrawerProtocol,
        .rectangle: RectanglePathDrawer() as any PenToolPathDrawerProtocol,
        .rectangleFill: RectangleFillPathDrawer() as any PenToolPathDrawerProtocol,
        .line: LinePathDrawer() as any PenToolPathDrawerProtocol,
        .text: TextPathDrawer() as any PenToolPathDrawerProtocol,
        .eraser: EraserPathDrawer() as any PenToolPathDrawerProtocol,
        .connectedCircles: ConnectedCirclesPathDrawer() as any PenToolPathDrawerProtocol
    ]

    private(set) var currentChain: ConnectedCirclesPath? = nil
    private(set) var isChainInHistory: Bool = false

    let pathHistory: PenToolPathHistory

    init(pathHistory: PenToolPathHistory) {
        self.pathHistory = pathHistory
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(onSelectDrawnPath(notification:)),
                                               name: .clickedDrawnPathNotification,
                                               object: nil)
    }

    @objc func onSelectDrawnPath(notification: NSNotification?) {
        pathHistory.clearSelectedStateOfPath()
        if notification == nil { return }
        let pathId = notification!.userInfo!["pathId"] as! Int

        if currentType == .eraser {
            pathHistory.removeDrawn(pathId: pathId)
            return
        }

        var selectedPath = pathHistory.selectPath(pathId: pathId)
        if selectedPath == nil { return }
        changeType(to: selectedPath!.type)
        selectedPath = pathHistory.selectPath(pathId: pathId)
        drawers[currentType]!.style.copyValues(from: selectedPath!.drawnStyle())
    }

    func changeType(to type: PenToolType) {
        pathHistory.clearSelectedStateOfPath()
        currentChain = nil
        isChainInHistory = false
        currentType = type
        AppDelegate.instance.switchPlayerStepAndSkipRewind(isEnabled: currentType != .text)
    }

    func styleOf(_ type: PenToolType) -> PenToolPathStyle {
        return drawers[type]!.style
    }

    func isValidInput(start: CGPoint, end: CGPoint) -> Bool {
        return drawers[currentType]!.isValidInput(startInResolution: start, endInResolution: end)
    }

    /// Returns a path for live preview (does NOT mutate the confirmed chain).
    /// For connectedCircles: returns a temporary single-circle path for preview.
    func makePreviewPath(centerInResolution: CGPoint, endInResolution: CGPoint) -> any PenToolPathProtocol {
        var p = ConnectedCirclesPath()
        p.initialize(startInResolution: centerInResolution, endInResolution: endInResolution)
        return p
    }

    func makePath(startInResolution: CGPoint, endInResolution: CGPoint) -> any PenToolPathProtocol {
        return drawers[currentType]!.makePath(startInResolution: startInResolution,
                                              endInResolution: endInResolution)
    }

    /// Confirms a new circle into the chain. Call only on drag-end with valid radius.
    func addCircleToChain(center: CGPoint, radius: CGFloat) {
        if let chain = currentChain {
            chain.appendNode(center, radius: max(radius, 5))
        } else {
            var p = ConnectedCirclesPath()
            let r = max(radius, 5)
            // initialize expects start=center, end=radius-point; distance = radius
            p.initialize(startInResolution: center,
                         endInResolution: CGPoint(x: center.x + r, y: center.y))
            currentChain = p
        }
    }

    func markChainInHistory() {
        isChainInHistory = true
    }

    func endChain() {
        currentChain = nil
        isChainInHistory = false
    }

    func saveStyle() {
        drawers[currentType]!.saveStyle()
    }
}
