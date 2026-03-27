//
//  ButtonStaticIcon.swift
//  SoccerCut Pro
//
//  Created by Naoki Tanaka on 2023/05/25.
//

import SwiftUI

struct ButtonStaticIcon: View {
    private let size: CGFloat
    private let imgName: String
    private let onClick: () -> Void
    
    init(size: CGFloat, imgName: String, onClick: @escaping () -> Void) {
        self.size = size
        self.imgName = imgName
        self.onClick = onClick
    }
    
    var body: some View {
        ButtonDynamicIcon(size: size, imgName: .constant(imgName), onClick: onClick)
    }
}

struct ButtonStaticIcon_Previews: PreviewProvider {
    static var previews: some View {
        ButtonStaticIcon(size: 80, imgName: "play") {
            // do nothing
        }
    }
}
