//
//  DashedArrowButton.swift
//  SoccerCut Pro
//
//  Created by Naoki Tanaka on 2023/07/31.
//

import SwiftUI

struct DashedArrowButton: View {
    @ObservedObject private(set) var pathFactory: PenToolPathFactory

    init() {
        self.pathFactory = PenToolModel.now.pathFactory
    }
    
    var body: some View {
        Button(action: {
            pathFactory.changeType(to: .dashedArrow)
        })
        {
            ZStack {
                Image(systemName: "chevron.right")
                    .font(.system(size: PenToolTypeButton.size))
                    .foregroundColor(pathFactory.currentType == .dashedArrow ? PenToolTypeButton.selectedColor : PenToolTypeButton.iconColor)
                    .offset(x: PenToolTypeButton.size * 0.15, y: 0)
                    .rotation3DEffect(.degrees(-45), axis: (x: 0, y: 0, z: 1))
                
                Image(systemName: "ellipsis")
                    .font(.system(size: PenToolTypeButton.size))
                    .foregroundColor(pathFactory.currentType == .dashedArrow ? PenToolTypeButton.selectedColor : PenToolTypeButton.iconColor)
                    .offset(x: PenToolTypeButton.size * (-0.1), y: 0)
                    .rotation3DEffect(.degrees(-45), axis: (x: 0, y: 0, z: 1))
            }
            .background(PenToolTypePanel.backgroundColor) // クリック可能範囲をアイコンからframeまで拡張する
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct DashedArrowButton_Previews: PreviewProvider {
    static var previews: some View {
        DashedArrowButton()
            .background(.gray)
    }
}
