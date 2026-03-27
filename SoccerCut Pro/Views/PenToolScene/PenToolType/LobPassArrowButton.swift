//
//  LobPassArrowImage.swift
//  SoccerCut Pro
//
//  Created by Naoki Tanaka on 2023/07/31.
//

import SwiftUI

struct LobPassArrowButton: View {
    @ObservedObject private(set) var pathFactory: PenToolPathFactory

    init() {
        self.pathFactory = PenToolModel.now.pathFactory
    }
    
    var body: some View {
        Button(action: {
            pathFactory.changeType(to: .lobPassArrow)
        })
        {
            Group {
                Image(systemName: "arrow.uturn.down")
                    .font(.system(size: PenToolTypeButton.size))
                    .foregroundColor(pathFactory.currentType == .lobPassArrow ? PenToolTypeButton.selectedColor : PenToolTypeButton.iconColor)
                    .rotation3DEffect(.degrees(180), axis: (x: 0, y: 1, z: 0))
            }
            .background(PenToolTypePanel.backgroundColor) // クリック可能範囲をアイコンからframeまで拡張する
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct LobPassArrowImage_Previews: PreviewProvider {
    static var previews: some View {
        LobPassArrowButton()
            .background(.gray)
    }
}
