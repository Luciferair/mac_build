//
//  PenToolEditButton.swift
//  SoccerCut Pro
//
//  Created by Naoki Tanaka on 2023/11/01.
//

import SwiftUI

struct PenToolEditButton: View {
    static let size: CGFloat = 20
    static let iconColor: Color = .white
    
    private let systemImageName: String
    private let onClick: () -> Void
    
    init(systemImageName: String, onClick: @escaping () -> Void) {
        self.systemImageName = systemImageName
        self.onClick = onClick
    }
    
    var body: some View {
        Button(action: { onClick() })
        {
            Group {
                Image(systemName: systemImageName)
                    .font(.system(size: PenToolEditButton.size))
                    .foregroundColor(PenToolEditButton.iconColor)
            }
            .background(PenToolEditPanel.backgroundColor) // クリック可能範囲をアイコンからframeまで拡張する
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct PenToolEditButton_Previews: PreviewProvider {
    static var previews: some View {
        PenToolEditButton(systemImageName: "play") {
            // do nothing
        }.background(.gray)
    }
}
