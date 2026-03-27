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

    /// Chain state for connectedCircles tool
    private(set) var currentChain: ConnectedCirclesPath? = nil
    /// True once the chain has been added to pathHistory (so subsequent segments don't re-add it)
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
        // 一旦全ての選択状態を解除
        pathHistory.clearSelectedStateOfPath()
        
        if notification == nil { return }
        let pathId = notification!.userInfo!["pathId"] as! Int
        
        // 消しゴム使用中なら選択したパスを消す
        if currentType == .eraser {
            pathHistory.removeDrawn(pathId: pathId)
            return
        }
        
        // クリックしたPathを取得
        var selectedPath = pathHistory.selectPath(pathId: pathId)
        
        // クリックしたPathのペンツールに変更
        if selectedPath == nil { return }
        changeType(to: selectedPath!.type)
        
        // Typeを変更すると選択解除されるので再度選択状態にする
        selectedPath = pathHistory.selectPath(pathId: pathId)
        
        // クリックしたPathのStyleに変更
        drawers[currentType]!.style.copyValues(from: selectedPath!.drawnStyle())
    }
    
    func changeType(to type: PenToolType) {
        // 選択解除
        pathHistory.clearSelectedStateOfPath()
        // チェーンをリセット
        currentChain = nil
        isChainInHistory = false
        
        currentType = type
        // テキスト編集の際、カーソル移動とプレーヤーのStepのキー入力が競合するので後者をOFFにする
        AppDelegate.instance.switchPlayerStepAndSkipRewind(isEnabled: currentType != .text)
    }
        
    func styleOf(_ type: PenToolType) -> PenToolPathStyle {
        return drawers[type]!.style
    }
    
    func isValidInput(start: CGPoint, end: CGPoint) -> Bool {
        let currentDrawer = drawers[currentType]!
        return currentDrawer.isValidInput(startInResolution: start, endInResolution: end)
    }
    
    func makePath(startInResolution: CGPoint, endInResolution: CGPoint) -> any PenToolPathProtocol {
        if currentType == .connectedCircles {
            if let chain = currentChain {
                // Extend existing chain: update the last (preview) node
                chain.updateLastNode(endInResolution)
                return chain
            } else {
                // Start a new chain
                var p = ConnectedCirclesPath()
                p.initialize(startInResolution: startInResolution, endInResolution: endInResolution)
                currentChain = p
                return p
            }
        }
        let currentDrawer = drawers[currentType]!
        return currentDrawer.makePath(startInResolution: startInResolution, endInResolution: endInResolution)
    }

    /// Called when a connectedCircles drag is confirmed. Appends a new preview node so the
    /// next drag extends the chain from the confirmed endpoint.
    func confirmChainSegment(endInResolution: CGPoint) {
        currentChain?.appendNode(endInResolution)
    }

    func markChainInHistory() {
        isChainInHistory = true
    }

    /// Finalises the chain (e.g. double-click or tool switch). Resets currentChain.
    func endChain() {
        currentChain = nil
        isChainInHistory = false
    }

    func saveStyle() {
        let currentDrawer = drawers[currentType]!
        currentDrawer.saveStyle()
    }
}
