//
//  DashedLobPassArrowButton.swift
//  SoccerCut Pro

import SwiftUI

struct DashedLobPassArrowButton: View {
    @ObservedObject private(set) var pathFactory: PenToolPathFactory

    init() { self.pathFactory = PenToolModel.now.pathFactory }

    var body: some View {
        Button(action: { pathFactory.changeType(to: .dashedLobPassArrow) }) {
            ZStack {
                // arc shape to suggest curved arrow
                Image(systemName: "arrow.up.right")
                    .font(.system(size: PenToolTypeButton.size * 0.8))
                    .foregroundColor(pathFactory.currentType == .dashedLobPassArrow ? PenToolTypeButton.selectedColor : PenToolTypeButton.iconColor)
                    .offset(x: PenToolTypeButton.size * 0.1, y: -PenToolTypeButton.size * 0.1)

                Image(systemName: "ellipsis")
                    .font(.system(size: PenToolTypeButton.size * 0.7))
                    .foregroundColor(pathFactory.currentType == .dashedLobPassArrow ? PenToolTypeButton.selectedColor : PenToolTypeButton.iconColor)
                    .offset(x: -PenToolTypeButton.size * 0.15, y: PenToolTypeButton.size * 0.15)
                    .rotation3DEffect(.degrees(-30), axis: (x: 0, y: 0, z: 1))
            }
            .background(PenToolTypePanel.backgroundColor)
        }
        .buttonStyle(PlainButtonStyle())
    }
}
