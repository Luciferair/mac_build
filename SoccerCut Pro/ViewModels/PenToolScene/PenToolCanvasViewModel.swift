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
        get { return CGSize(width: player.resolution.width * resolutionToVideoRectSizeRatio.width,
                            height: player.resolution.height * resolutionToVideoRectSizeRatio.height) }
    }
    
    init() {
        player = PenToolModel.now.player
        pathFactory = PenToolModel.now.pathFactory
        pathHistory = PenToolModel.now.pathHistory
        NotificationCenter.default.addObserver(self, selector: #selector(self.updateDrawnPath), name: .drawnPathDidChangeNotification, object: pathHistory)
    }
    
    func resizePaths(canvasOrigin: CGPoint, newVideoRect: CGRect) {
        Task { @MainActor in // エラー対策: Publishing changes from within view updates is not allowed, this will cause undefined behavior.
            resolutionToVideoRectSizeRatio.width = newVideoRect.width / player.resolution.width
            resolutionToVideoRectSizeRatio.height = newVideoRect.height / player.resolution.height
        }
    }
    
    func onStartDrag() {
        pathHistory.clearSelectedStateOfPath()
    }

    func onDoubleClick() {
        // End the connectedCircles chain so the next drag starts a fresh one
        pathFactory.endChain()
    }
    
    func onDrag(startLocationInVideoRect: CGPoint, locationInVideoRect: CGPoint, isEnd: Bool) {
        if player.isPlaying { player.togglePlayPause() } // 描画が始まったら強制的に一時停止にする
        
        let startLocationInResolution = videoRectToResolution(locationInVideoRect: startLocationInVideoRect)
        let locationInResolution = videoRectToResolution(locationInVideoRect: locationInVideoRect)
        
        if !pathFactory.isValidInput(start: startLocationInResolution, end: locationInResolution) {
            pathHistory.clearDrawing()
            return
        }
        
        let path = pathFactory.makePath(startInResolution: startLocationInResolution, endInResolution: locationInResolution)
        if isEnd {
            if pathFactory.currentType == .connectedCircles {
                if pathFactory.isChainInHistory {
                    // Subsequent segment: chain already in history, just extend it
                    pathFactory.confirmChainSegment(endInResolution: locationInResolution)
                    pathHistory.clearDrawing()
                    NotificationCenter.default.post(name: .drawnPathDidChangeNotification, object: pathHistory,
                                                    userInfo: ["targetFrame": pathHistory.currentTargetFrame])
                } else {
                    // First segment: add chain to history
                    pathFactory.confirmChainSegment(endInResolution: locationInResolution)
                    pathFactory.markChainInHistory()
                    pathHistory.confirmDrawing(type: pathFactory.currentType, path: path)
                    pathFactory.saveStyle()
                }
            } else {
                pathHistory.confirmDrawing(type: pathFactory.currentType, path: path)
                pathFactory.saveStyle()
            }
        } else {
            pathHistory.updateDrawing(type: pathFactory.currentType, path: path)
        }
    }
    
    // 表示中の動画の座標から動画のオリジナルの解像度上の座標に変換
    func videoRectToResolution(locationInVideoRect: CGPoint) -> CGPoint {
        var locationInResolution = locationInVideoRect
        locationInResolution.x /= resolutionToVideoRectSizeRatio.width
        locationInResolution.y /= resolutionToVideoRectSizeRatio.height
        
        return locationInResolution
    }
    
    @objc func updateDrawnPath() {
        drawnPathsOnCurrentFrame = pathHistory.currentTargetFrameDrawns
        drawingPathOnCurrentFrame = pathHistory.drawing
    }
}
