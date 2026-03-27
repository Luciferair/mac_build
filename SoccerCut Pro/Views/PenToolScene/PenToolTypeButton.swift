//
//  PenToolTypeButton.swift
//  SoccerCut Pro
//
//  Created by Naoki Tanaka on 2023/07/31.
//

import SwiftUI

struct PenToolTypeButton: View {
    @ObservedObject private(set) var pathFactory: PenToolPathFactory
        
    static let size: CGFloat = 20
    static let iconColor: Color = .white
    static let selectedColor: Color = .yellow
    
    private let systemImageName: String
    private let type: PenToolType
    
    init(systemImageName: String, type: PenToolType) {
        self.pathFactory = PenToolModel.now.pathFactory
        self.systemImageName = systemImageName
        self.type = type
    }
    
    var body: some View {
        Button(action: {
            pathFactory.changeType(to: type)
        })
        {
            Group {
                Image(systemName: systemImageName)
                    .font(.system(size: PenToolTypeButton.size))
                    .foregroundColor(pathFactory.currentType == type ? PenToolTypeButton.selectedColor : PenToolTypeButton.iconColor)
            }
            .background(PenToolTypePanel.backgroundColor) // クリック可能範囲をアイコンからframeまで拡張する
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct PenToolTypeButton_Previews: PreviewProvider {
    static var previews: some View {
        PenToolTypeButton(systemImageName: "play", type: .arrow)
            .background(.gray)
    }
}
