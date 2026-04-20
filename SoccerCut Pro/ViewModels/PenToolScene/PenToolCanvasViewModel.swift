//
//  PenToolCanvasViewModel.swift
//  SoccerCut Pro
//
//  Created by Naoki Tanaka on 2023/09/03.
//

import Cocoa
import SwiftUI

class PenToolCanvasViewModel: ObservableObject {
    private let player: PenToolPlayer
    private let pathFactory: PenToolPathFactory
    private let pathHistory: PenToolPathHistory
    @Published private(set) var resolutionToVideoRectSizeRatio = CGSize(width: 1, height: 1)
    @Published private(set) var drawnPathsOnCurrentFrame: [PenToolDrawnPath] = []
    @Published private(set) var drawingPathOnCurrentFrame: PenToolDrawnPath? = nil

    var videoRect: CGSize {
        CGSize(width: player.resolution.width * resolutionToVideoRectSizeRatio.width,
               height: player.resolution.height * resolutionToVideoRectSizeRatio.height)
    }

    init() {
        player = PenToolModel.now.player
        pathFactory = PenToolModel.now.pathFactory
        pathHistory = PenToolModel.now.pathHistory
        NotificationCenter.default.addObserver(self, selector: #selector(self.updateDrawnPath),
                                               name: .drawnPathDidChangeNotification, object: pathHistory)
    }

    func resizePaths(canvasOrigin: CGPoint, newVideoRect: CGRect) {
        Task { @MainActor in
            resolutionToVideoRectSizeRatio.width  = newVideoRect.width  / player.resolution.width
            resolutionToVideoRectSizeRatio.height = newVideoRect.height / player.resolution.height
        }
    }

    func onStartDrag() {
        pathHistory.clearSelectedStateOfPath()
    }

    func onDoubleClick() {
        pathFactory.endChain()
    }

    func onDrag(startLocationInVideoRect: CGPoint, locationInVideoRect: CGPoint, isEnd: Bool) {
        if player.isPlaying { player.togglePlayPause() }

        let centerInResolution = videoRectToResolution(locationInVideoRect: startLocationInVideoRect)
        let edgeInResolution   = videoRectToResolution(locationInVideoRect: locationInVideoRect)
        let radius = (edgeInResolution - centerInResolution).length

        if pathFactory.currentType == .connectedCircles {
            if !isEnd {
                // Show a live preview circle (standalone, not yet in chain)
                let preview = pathFactory.makePreviewPath(centerInResolution: centerInResolution,
                                                          endInResolution: edgeInResolution)
                pathHistory.updateDrawing(type: pathFactory.currentType, path: preview)
            } else {
                pathHistory.clearDrawing()
                guard radius >= 3 else { return }

                // Confirm this circle into the chain
                pathFactory.addCircleToChain(center: centerInResolution,
                                             radius: radius,
                                             previewEnd: edgeInResolution)

                guard let chain = pathFactory.currentChain else { return }

                if pathFactory.isChainInHistory {
                    // Chain already in history — it's a reference type, SwiftUI will re-render
                    NotificationCenter.default.post(name: .drawnPathDidChangeNotification,
                                                    object: pathHistory,
                                                    userInfo: ["targetFrame": pathHistory.currentTargetFrame])
                    // Re-select the chain path so angle/style sliders work
                    if let chainPath = pathHistory.currentTargetFrameDrawns.last(where: { $0.type == .connectedCircles }) {
                        pathHistory.selectPathWithoutClear(pathId: chainPath.id)
                    }
                } else {
                    // First circle — add chain to history
                    pathFactory.markChainInHistory()
                    pathHistory.confirmDrawing(type: pathFactory.currentType, path: chain)
                    pathFactory.saveStyle()
                    // Auto-select so angle/degree sliders work immediately
                    if let lastDrawn = pathHistory.currentTargetFrameDrawns.last {
                        pathHistory.selectPathWithoutClear(pathId: lastDrawn.id)
                    }
                }
            }
            return
        }

        // All other tools
        if !pathFactory.isValidInput(start: centerInResolution, end: edgeInResolution) {
            pathHistory.clearDrawing()
            return
        }

        let path = pathFactory.makePath(startInResolution: centerInResolution,
                                        endInResolution: edgeInResolution)
        if isEnd {
            pathHistory.confirmDrawing(type: pathFactory.currentType, path: path)
            pathFactory.saveStyle()
        } else {
            pathHistory.updateDrawing(type: pathFactory.currentType, path: path)
        }
    }

    func videoRectToResolution(locationInVideoRect: CGPoint) -> CGPoint {
        CGPoint(x: locationInVideoRect.x / resolutionToVideoRectSizeRatio.width,
                y: locationInVideoRect.y / resolutionToVideoRectSizeRatio.height)
    }

    @objc func updateDrawnPath() {
        drawnPathsOnCurrentFrame = pathHistory.currentTargetFrameDrawns
        drawingPathOnCurrentFrame = pathHistory.drawing
    }
}
