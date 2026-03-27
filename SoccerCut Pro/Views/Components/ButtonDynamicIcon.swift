//
//  ButtonDynamicIcon.swift
//  SoccerCut Pro
//
//  Created by Naoki Tanaka on 2023/05/29.
//

import SwiftUI

struct ButtonDynamicIcon: View {
    private let size: CGFloat
    @Binding var imgName: String
    @Binding var subImgName: String
    @Binding var isFlippedX: Bool
    private let onClick: () -> Void
    
    init(size: CGFloat, imgName: Binding<String>, subImgName: Binding<String> = .constant(""),
         isFlippedX: Binding<Bool> = .constant(false), onClick: @escaping () -> Void) {
        self.size = size
        self._imgName = imgName
        self._subImgName = subImgName
        self._isFlippedX = isFlippedX
        self.onClick = onClick
    }
    
    var body: some View {
        Button(action: {
            onClick()
        }) {
            ZStack {
                Image(systemName: imgName)
                    .font(.system(size: size))
                    .foregroundColor(.white)
                    .rotation3DEffect(.degrees(isFlippedX ? 180 : 0),
                                          axis: (x: 0, y: 1, z: 0))
                if subImgName != "" {
                    Image(systemName: subImgName)
                        .font(.system(size: size * 0.5))
                        .foregroundColor(.white)
                        .offset(x: size * 0, y: size * (-0.05))
                        .rotation3DEffect(.degrees(isFlippedX ? 180 : 0),
                                              axis: (x: 0, y: 1, z: 0))
                }
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct ButtonDynamicIcon_Previews: PreviewProvider {
    static var previews: some View {
        ButtonDynamicIcon(size: 40, imgName: .constant("play")) {
            // do nothing
        }
    }
}
