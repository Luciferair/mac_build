//
//  PenToolEffectThumbnailViewModel.swift
//  SoccerCut Pro
//
//  Created by Naoki Tanaka on 2023/09/30.
//

import AVFoundation
import Cocoa
import SwiftUI

class PenToolEffectThumbnailViewModel: ObservableObject {
    private let player: PenToolPlayer
    private let pathHistory: PenToolPathHistory
    
    @Published private(set) var thumbnailScale: CGFloat = .zero
    @Published private(set) var resolutionToThumbnailSizeRatio: CGFloat = .zero
    @Published private(set) var drawnPaths: [PenToolDrawnPath] = []
    @Published private(set) var drawingPath: PenToolDrawnPath? = nil
    @Published private(set) var effectFrozenSecs: Double = 0.0
    
    let frameSecs: Double
    let thumbnail: CGImage
        
    init(frameSecs: Double, thumbnail: CGImage) {
        player = PenToolModel.now.player
        pathHistory = PenToolModel.now.pathHistory
        
        // 感覚と異なるが、scaleが1を超えると元より小さくなる
        let padding: CGFloat = 32
        thumbnailScale = player.resolution.width / (PenToolEffectThumbnailListPanel.effectListPanelWidth - padding)
        // thumbnailScaleの逆数だが精度を考えきっちり計算する
        resolutionToThumbnailSizeRatio = (PenToolEffectThumbnailListPanel.effectListPanelWidth - padding) / player.resolution.width
        
        self.frameSecs = frameSecs
        self.thumbnail = thumbnail
        
        // サムネイル生成時はNotificationCenterが間に合わず描画が更新されないので手動で呼び出す
        updateDrawnPath()
        
        // エフェクト表示時間の変更に追従するため監視
        let timeInterval = 0.2
        Timer.scheduledTimer(withTimeInterval: timeInterval, repeats: true, block: { (timer) in
            self.effectFrozenSecs = self.pathHistory.showingEffectSecsDict[self.frameSecs] ?? 0.0
        })

        NotificationCenter.default.addObserver(self, selector: #selector(self.updateDrawnPath), name: .drawnPathDidChangeNotification, object: pathHistory)
    }
    
    @objc func updateDrawnPath() {
        if frameSecs == pathHistory.currentTargetFrame.seconds {
            drawnPaths = pathHistory.currentTargetFrameDrawns
            drawingPath = pathHistory.drawing
        } else {
            drawnPaths = pathHistory.drawnsWithoutCurrentTargetFrame[frameSecs] ?? []
            drawingPath = nil
        }
    }
    
    func jumpToThisFrame() {
        if (player.isPlaying) { player.togglePlayPause() }
        player.seekTo(frameSecs)
    }
}
