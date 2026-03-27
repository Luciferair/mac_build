//
//  PenToolPathProtocol.swift
//  SoccerCut Pro
//
//  Created by Naoki Tanaka on 2023/09/01.
//

import SwiftUI

protocol PenToolPathProtocol: View {
    func drawnStyle() -> PenToolPathStyle
    func applyStyle(_ newStyle: PenToolPathStyle)
    func drawnTransform() -> PenToolPathTransform
    func applyTransform(_ newTransform: PenToolPathTransform)
    func offset() -> CGSize
    func frame() -> CGSize
    func onDragged(startInVideoRect: CGPoint, endInVideoRect: CGPoint)
    func onDragEnded(startInVideoRect: CGPoint, endInVideoRect: CGPoint)
}
