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
            LobPassArrowButton()
            DashedArrowButton()
            DashedLobPassArrowButton()
            CircleButton()
            PenToolTypeButton(systemImageName: "circle.fill", type: .circleFill)
            PenToolTypeButton(systemImageName: "circle.grid.2x1", type: .connectedCircles)
            PenToolTypeButton(systemImageName: "triangle", type: .triangle)
            PenToolTypeButton(systemImageName: "triangle.fill", type: .triangleFill)
            PenToolTypeButton(systemImageName: "rectangle", type: .rectangle)
            PenToolTypeButton(systemImageName: "rectangle.fill", type: .rectangleFill)
            PenToolTypeButton(systemImageName: "line.diagonal", type: .line)
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
