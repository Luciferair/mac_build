//
//  PenToolPaths.swift
//  SoccerCut Pro
//
//  Created by Naoki Tanaka on 2023/08/06.
//

import AVFoundation
import Cocoa
import SwiftUI

class PenToolPathHistory {
    private(set) var currentTargetFrame: CMTime = .zero // 値を変更する場合はchangeFrame関数を使用すること
    private(set) var drawing: PenToolDrawnPath? = nil // いま描画中のPath
    private(set) var currentTargetFrameDrawns: [PenToolDrawnPath] = [] // すでに描いたPath
    private(set) var drawnsWithoutCurrentTargetFrame: Dictionary<Double, [PenToolDrawnPath]> = [:] // 現在のフレーム以外の既に描いたPath
    private(set) var currentShowingEffectSecsSetting: Double = 5.0
    private(set) var showingEffectSecsDict: Dictionary<Double, Double> = [:] // エフェクト表示秒数、キーはframeSecs。undo/redoされた時のことを考え一度設定されたキーは全て保持しておく。
    private(set) var steps: [PenToolUndoableStep] = [] // undoする時の操作Step（全フレーム込み）
    private(set) var undoneSteps: [PenToolUndoableStep] = [] // undoされたStep（全フレーム込み）
    private var drawnId: Int = 0 // Idをdrawns.countにしてしまうと途中でPathが削除された時に重複してしまうので別途用意
    
    var allDrawnPaths: Dictionary<Double, [PenToolDrawnPath]> {
        var outputDict = drawnsWithoutCurrentTargetFrame
        if !currentTargetFrameDrawns.isEmpty { outputDict[currentTargetFrame.seconds] = currentTargetFrameDrawns }
        return outputDict
    }
    
    let player: PenToolPlayer
    
    init (player: PenToolPlayer) {
        self.player = player
        // 下記の両方を検知したい
        // ・一時停止
        // ・一時停止中のstepやseek等による移動
        NotificationCenter.default.addObserver(self, selector: #selector(self.changeFrameToStartDrawing), name: AVPlayer.rateDidChangeNotification, object: self.player)
        NotificationCenter.default.addObserver(self, selector: #selector(self.changeFrameToStartDrawing), name: AVPlayerItem.timeJumpedNotification, object: self.player.currentItem)
        NotificationCenter.default.addObserver(self, selector: #selector(self.clearSelectedStateOfPath), name: .drawnPathDidChangeNotification, object: self)
    }
    
    
    @objc func changeFrameToStartDrawing() {        
        changeTargetFrame(to: player.isPlaying ? .indefinite : player.currentTime)
        // Reset any in-progress connectedCircles chain when the frame changes
        PenToolModel.now.pathFactory.endChain()
    }

    func changeTargetFrame(to newTargetFrame: CMTime) {
        if currentTargetFrame == newTargetFrame { return }
        
        // 最終描画フレームの描画パスを描画履歴に保存
        if currentTargetFrame == .indefinite {
            // do nothing
        }
        else if currentTargetFrameDrawns.isEmpty { // 最後に描画したフレームにパスが1つもないなら履歴の対象フレームから消す
            drawnsWithoutCurrentTargetFrame.removeValue(forKey: currentTargetFrame.seconds)
        } else { // 最後に描画したフレームのパスを履歴に保存
            drawnsWithoutCurrentTargetFrame[currentTargetFrame.seconds] = currentTargetFrameDrawns
        }
        
        // 新フレームの描画パスをロード & 履歴からは一旦削除
        if newTargetFrame == .indefinite {
            currentTargetFrameDrawns = []
        } else {
            currentTargetFrameDrawns = drawnsWithoutCurrentTargetFrame[newTargetFrame.seconds] ?? []
            drawnsWithoutCurrentTargetFrame.removeValue(forKey: newTargetFrame.seconds)
        }
            
        currentTargetFrame = newTargetFrame
        currentShowingEffectSecsSetting = showingEffectSecsDict[currentTargetFrame.seconds] ?? currentShowingEffectSecsSetting
        
        NotificationCenter.default.post(name: .drawnPathDidChangeNotification, object: self, userInfo: ["targetFrame": currentTargetFrame])
    }
    
    func updateDrawing(type: PenToolType, path: any PenToolPathProtocol) {
        drawing = PenToolDrawnPath(id: drawnId, type: type, path: path)
        NotificationCenter.default.post(name: .drawnPathDidChangeNotification, object: self, userInfo: ["targetFrame": currentTargetFrame])
    }
    
    func confirmDrawing(type: PenToolType, path: any PenToolPathProtocol) {
        let newPath = PenToolDrawnPath(id: drawnId, type: type, path: path)
        drawnId += 1
        
        steps.append(PenToolUndoableStep(id: steps.count, frameTime: currentTargetFrame, newPath: newPath))
        currentTargetFrameDrawns.append(newPath)
        showingEffectSecsDict[currentTargetFrame.seconds] = currentShowingEffectSecsSetting
        drawing = nil
        undoneSteps = []
        NotificationCenter.default.post(name: .drawnPathDidChangeNotification, object: self, userInfo: ["targetFrame": currentTargetFrame])
    }
    
    func clearDrawing() {
        drawing = nil
        NotificationCenter.default.post(name: .drawnPathDidChangeNotification, object: self, userInfo: ["targetFrame": currentTargetFrame])
    }
    
    func addTransformUndoableStep(oldTransform: PenToolPathTransform) {
        guard let selectedPath = selectedPath() else { return }
        steps.append(PenToolUndoableStep(id: steps.count, frameTime: currentTargetFrame, path: selectedPath, oldTransform: oldTransform))
        undoneSteps = []
    }
    
    @objc func clearSelectedStateOfPath() {
        for drawnPath in currentTargetFrameDrawns {
            drawnPath.setIsSelected(false)
        }
    }
        
    func removeDrawn(pathId: Int) {
        var removeIndex = -1
        for i in 0 ..< currentTargetFrameDrawns.count {
            if currentTargetFrameDrawns[i].id == pathId {
                removeIndex = i
                break
            }
        }
        if (removeIndex < 0) { return } // ダブルクリック等で既に消えているのに再度消しゴムを適用しようとするとクラッシュするので回避
        
        steps.append(PenToolUndoableStep(id: steps.count, frameTime: currentTargetFrame, oldPath: currentTargetFrameDrawns[removeIndex]))
        currentTargetFrameDrawns.remove(at: removeIndex)
        drawing = nil
        undoneSteps = []
        NotificationCenter.default.post(name: .drawnPathDidChangeNotification, object: self, userInfo: ["targetFrame": currentTargetFrame])
    }
    
    func selectPath(pathId: Int) -> PenToolDrawnPath? {
        for drawnPath in currentTargetFrameDrawns {
            if drawnPath.id == pathId {
                drawnPath.setIsSelected(true)
                return drawnPath
            }
        }
        return nil
    }
    
    func selectedPath() -> PenToolDrawnPath? {
        for drawnPath in currentTargetFrameDrawns {
            if drawnPath.isSelected {
                return drawnPath
            }
        }
        return nil
    }
    
    func applyStyleToSelectedPath(_ newStyle: PenToolPathStyle) {
        for drawnPath in currentTargetFrameDrawns {
            if drawnPath.isSelected { drawnPath.applyStyle(newStyle) }
        }
    }
    
    func changeShowingEffectSecs(newSecs: Double) {
        currentShowingEffectSecsSetting = newSecs
        showingEffectSecsDict[currentTargetFrame.seconds] = currentShowingEffectSecsSetting
    }
    
    func undo() {
        guard let last = steps.last else { return }
        
        changeTargetFrame(to: last.frameTime)
        player.seekTo(last.frameTime.seconds)
        
        if last.oldPath != nil && last.newPath != nil { // Transform変更をUndo
            last.oldPath!.applyTransform(last.oldTransform!)
        }
        else if last.oldPath == nil { // 新規Path描画をUndo
            currentTargetFrameDrawns.removeLast()
        }
        else if last.newPath == nil { // Path削除をUndo
            currentTargetFrameDrawns.append(last.oldPath!)
            currentTargetFrameDrawns.sort(by: {$0.id < $1.id})
        }

        undoneSteps.append(last)
        steps.removeLast()
        NotificationCenter.default.post(name: .drawnPathDidChangeNotification, object: self, userInfo: ["targetFrame": currentTargetFrame])
    }
    
    func redo() {
        guard let last = undoneSteps.last else { return }
        
        changeTargetFrame(to: last.frameTime)
        player.seekTo(last.frameTime.seconds)
        
        if last.oldPath != nil && last.newPath != nil { // Transform変更をRedo
            last.newPath!.applyTransform(last.newTransform!)
        }
        else if last.oldPath == nil { // 新規Path描画をRedo
            currentTargetFrameDrawns.append(last.newPath!) // 必ず末尾なのでソート不要
        }
        else if last.newPath == nil { // Path削除をRedo
            var removeIndex = -1
            for i in 0 ..< currentTargetFrameDrawns.count {
                if currentTargetFrameDrawns[i].id == last.oldPath!.id {
                    removeIndex = i
                    break
                }
            }
            currentTargetFrameDrawns.remove(at: removeIndex)
        }
        
        steps.append(last)
        undoneSteps.removeLast()
        NotificationCenter.default.post(name: .drawnPathDidChangeNotification, object: self, userInfo: ["targetFrame": currentTargetFrame])
    }
    
    func removeSelectedPath() {
        for drawnPath in currentTargetFrameDrawns {
            if drawnPath.isSelected {
                removeDrawn(pathId: drawnPath.id)
            }
        }
    }
    
    func clearAll() {
        if currentTargetFrameDrawns.isEmpty { return }
        
        let alert = NSAlert()
        alert.messageText = "削除確認"
        alert.informativeText = "現在表示しているフレームへの描画を全て削除します。\n（この操作は取消できません。）"
        
        alert.addButton(withTitle: "削除しない")
        alert.addButton(withTitle: "削除する")
        
        alert.buttons[0].tag = NSApplication.ModalResponse.cancel.rawValue
        alert.buttons[1].tag = NSApplication.ModalResponse.OK.rawValue
        alert.buttons[1].hasDestructiveAction = true
        
        let result = alert.runModal()
        
        if result == .OK {
            currentTargetFrameDrawns.removeAll()
            showingEffectSecsDict.removeAll()
            steps.removeAll()
            undoneSteps.removeAll()
            NotificationCenter.default.post(name: .drawnPathDidChangeNotification, object: self, userInfo: ["targetFrame": currentTargetFrame])
        }
    }
}
