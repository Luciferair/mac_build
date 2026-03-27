//
//  PenToolUndoableStep.swift
//  SoccerCut Pro
//
//  Created by Naoki Tanaka on 2023/08/16.
//

import AVFoundation

struct PenToolUndoableStep: Identifiable {
    let id: Int
    let frameTime: CMTime
    let oldPath: PenToolDrawnPath? // nil: 新規描画
    let newPath: PenToolDrawnPath? // nil: 削除された
    let oldStyle: PenToolPathStyle?
    let newStyle: PenToolPathStyle?
    let oldTransform: PenToolPathTransform?
    let newTransform: PenToolPathTransform?
    
    // 新規描画 or 描画済みパス削除
    init(
        id: Int,
        frameTime: CMTime,
        oldPath: PenToolDrawnPath? = nil,
        newPath: PenToolDrawnPath? = nil
    ) {
        self.id = id
        self.frameTime = frameTime
        self.oldPath = oldPath
        self.newPath = newPath
        
        if let oldStyle = oldPath?.drawnStyle() {
            self.oldStyle = PenToolPathStyle()
            self.oldStyle!.copyValues(from: oldStyle)
        } else {
            self.oldStyle = nil
        }
        if let newStyle = newPath?.drawnStyle() {
            self.newStyle = PenToolPathStyle()
            self.newStyle!.copyValues(from: newStyle)
        } else {
            self.newStyle = nil
        }
        
        if let oldTransform = oldPath?.drawnTransform() {
            self.oldTransform = PenToolPathTransform()
            self.oldTransform!.copyValues(from: oldTransform)
        } else {
            self.oldTransform = nil
        }
        if let newTransform = newPath?.drawnTransform() {
            self.newTransform = PenToolPathTransform()
            self.newTransform!.copyValues(from: newTransform)
        } else {
            self.newTransform = nil
        }
    }
    
    // 描画済みパスの移動
    init(
        id: Int,
        frameTime: CMTime,
        path: PenToolDrawnPath,
        oldTransform: PenToolPathTransform
    ) {
        self.id = id
        self.frameTime = frameTime
        self.oldPath = path
        self.newPath = path
        
        self.oldStyle = PenToolPathStyle()
        self.oldStyle!.copyValues(from: path.drawnStyle())
        self.newStyle = PenToolPathStyle()
        self.newStyle!.copyValues(from: path.drawnStyle())
        
        self.oldTransform = PenToolPathTransform()
        self.oldTransform!.copyValues(from: oldTransform)
        self.newTransform = PenToolPathTransform()
        self.newTransform!.copyValues(from: path.drawnTransform()) // 移動後のtransformはPathに反映されている
    }
}
