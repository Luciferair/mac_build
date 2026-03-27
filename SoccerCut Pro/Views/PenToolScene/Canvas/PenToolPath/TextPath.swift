//
//  TextPath.swift
//  SoccerCut Pro
//
//  Created by Naoki Tanaka on 2023/10/31.
//

import SwiftUI

struct TextPath: View, PenToolPathProtocol {
    let type: PenToolType = .text
    private let pathHistory: PenToolPathHistory
    @ObservedObject private var _drawnStyle = PenToolPathStyle()
    @ObservedObject private var transform = PenToolPathTransform()
    
    init() {
        pathHistory = PenToolModel.now.pathHistory
    }
    
    func initialize(startInResolution: CGPoint, endInResolution: CGPoint) {
        self._drawnStyle.copyValues(from: PenToolModel.now.pathFactory.styleOf(type))
        
        self.transform.start = startInResolution
        self.transform.end = endInResolution
    }
    
    func drawnStyle() -> PenToolPathStyle { return _drawnStyle }
    func applyStyle(_ newStyle: PenToolPathStyle) { self._drawnStyle.copyValues(from: newStyle) }
    func drawnTransform() -> PenToolPathTransform { return transform }
    func applyTransform(_ newTransform: PenToolPathTransform) { transform.copyValues(from: newTransform) }
    
    func offset() -> CGSize {
        return CGSize(width: transform.end.x - textSize().width/2,
                      height: transform.end.y - textSize().height/2)
               + transform.draggingOffset
    }
    func frame() -> CGSize { return textSize() }
    
    func onDragged(startInVideoRect: CGPoint, endInVideoRect: CGPoint) {
        self.transform.draggingOffset = CGSize(width: endInVideoRect.x - startInVideoRect.x,
                                               height: endInVideoRect.y - startInVideoRect.y)
    }
    
    func onDragEnded(startInVideoRect: CGPoint, endInVideoRect: CGPoint) {
        let transformOnDragStart = PenToolPathTransform()
        transformOnDragStart.copyValues(from: self.transform)
        transformOnDragStart.draggingOffset = .zero
        
        self.transform.start = self.transform.start + (endInVideoRect - startInVideoRect)
        self.transform.end = self.transform.end + (endInVideoRect - startInVideoRect)
        self.transform.draggingOffset = .zero
        
        pathHistory.addTransformUndoableStep(oldTransform: transformOnDragStart)
    }
    
    private func textSize() -> CGSize { return _drawnStyle.textString.size(withAttributes: [.font: NSFont.systemFont(ofSize: fontSize())]) }
    private func opacity() -> Double { return Double(_drawnStyle.opacity) / 100 }
    private func fontSize() -> CGFloat { return CGFloat(_drawnStyle.fontSize) }
            
    var body: some View {
        // GeometryReaderを使うとなぜかframeの位置とサイズがバグる問題が解決するので使っておく
        // offsetとframeは親View（PenToolDrawnPath）で設定。選択時の表示や処理のため。
        GeometryReader { geometry in
            Text(_drawnStyle.textString)
                .fixedSize(horizontal: true, vertical: true) // 文字を勝手に省略しないようにする
                .foregroundColor(_drawnStyle.color)
                .opacity(opacity())
                .font(.system(size: fontSize()))
//                    .border(.red, width: 3)
        }
    }
}

struct TextPath_Previews: PreviewProvider {
    static var previews: some View {
        EmptyView()
    }
}
