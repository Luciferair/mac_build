//
//  CircleButton.swift
//  SoccerCut Pro
//
//  Created by Naoki Tanaka on 2023/11/10.
//

import SwiftUI

struct CircleButton: View {
    @ObservedObject private(set) var pathFactory: PenToolPathFactory

    init() {
        self.pathFactory = PenToolModel.now.pathFactory
    }
    
    var body: some View {
        Button(action: {
            pathFactory.changeType(to: .connectedCircles)
        })
        {
            ZStack {
                Image(systemName: "circle")
                    .font(.system(size: PenToolTypeButton.size))
                    .foregroundColor(pathFactory.currentType == .connectedCircles ? PenToolTypeButton.selectedColor : PenToolTypeButton.iconColor)
                    .offset(x: 0, y: PenToolTypeButton.size * 0.9)
                    .scaleEffect(y: 0.5)
                
                Image(systemName: "figure.arms.open")
                    .font(.system(size: PenToolTypeButton.size))
                    .foregroundColor(pathFactory.currentType == .connectedCircles ? PenToolTypeButton.selectedColor : PenToolTypeButton.iconColor)
            }
            .background(PenToolTypePanel.backgroundColor) // クリック可能範囲をアイコンからframeまで拡張する
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct CircleButton_Previews: PreviewProvider {
    static var previews: some View {
        CircleButton()
            .background(.gray)
    }
}
                                                                                    