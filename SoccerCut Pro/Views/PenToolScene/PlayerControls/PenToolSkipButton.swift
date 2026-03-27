//
//  PenToolSkipButton.swift
//  SoccerCut Pro
//
//  Created by Naoki Tanaka on 2023/09/01.
//

import SwiftUI

struct PenToolSkipButton: View {
    @ObservedObject private var viewModel = PenToolSkipButtonViewModel()
    
    var body: some View {
        HStack {
            ButtonStaticIcon(size: 20, imgName: "forward.fill") { viewModel.onClick() }
            
            Text(viewModel.label)
                .frame(width: 50, alignment: .leading)
                .foregroundColor(.white)
        }
    }
}

struct PenToolSkipButton_Previews: PreviewProvider {
    static var previews: some View {
        PenToolSkipButton()
    }
}
