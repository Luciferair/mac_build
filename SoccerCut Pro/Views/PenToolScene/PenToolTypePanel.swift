//
//  PenToolTypePanel.swift
//  SoccerCut Pro
//
//  Created by Naoki Tanaka on 2023/07/28.
//

import SwiftUI

struct PenToolTypePanel: View {
    @ObservedObject private(set) var pathFactory: PenToolPathFactory
    static let backgroundColor: Color = .gray
    
    init() {
        pathFactory = PenToolModel.now.pathFactory
    }
    
    var body: some View {
        VStack(spacing: 10) {
            PenToolTypeButton(systemImageName: "arrow.up.right", type: .arrow)
            DashedArrowButton()
            LobPassArrowButton()
            DashedLobPassArrowButton()
            PenToolTypeButton(systemImageName: "line.diagonal", type: .line)
            CircleButton()
            // ConnectedCirclesButton()
            PenToolTypeButton(systemImageName: "circle.fill", type: .circleFill)
            PenToolTypeButton(systemImageName: "triangle", type: .triangle)
            PenToolTypeButton(systemImageName: "triangle.fill", type: .triangleFill)
            PenToolTypeButton(systemImageName: "rectangle", type: .rectangle)
            PenToolTypeButton(systemImageName: "rectangle.fill", type: .rectangleFill)
            PenToolTypeButton(systemImageName: "textformat.abc", type: .text)
            PenToolTypeButton(systemImageName: "eraser", type: .eraser)
            Spacer()
        }
        .padding(.vertical, 10)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(PenToolTypePanel.backgroundColor)
    }
}

struct PenToolsPanel_Previews: PreviewProvider {
    static var previews: some View {
        PenToolTypePanel()
    }
}

struct ConnectedCirclesButton: View {
    @ObservedObject private(set) var pathFactory: PenToolPathFactory

    init() {
        self.pathFactory = PenToolModel.now.pathFactory
    }

    private var iconColor: Color {
        pathFactory.currentType == .connectedCircles ? PenToolTypeButton.selectedColor : PenToolTypeButton.iconColor
    }

    var body: some View {
        Button(action: {
            pathFactory.changeType(to: .connectedCircles)
        }) {
            VStack(spacing: 1) {
                Image(systemName: "person.2")
                    .font(.system(size: PenToolTypeButton.size - 2))
                    .foregroundColor(iconColor)
                Capsule()
                    .fill(iconColor)
                    .frame(width: 12, height: 2)
            }
            .frame(height: PenToolTypeButton.size + 3)
            .background(PenToolTypePanel.backgroundColor)
        }
        .buttonStyle(PlainButtonStyle())
    }
}
