//
//  PenToolRewindButton.swift
//  SoccerCut Pro
//
//  Created by Naoki Tanaka on 2023/09/01.
//

import SwiftUI

struct PenToolRewindButton: View {
    @ObservedObject private var viewModel = PenToolRewindButtonViewModel()
    
    var body: some View {
        HStack {
            Text(viewModel.label)
                .frame(width: 50, alignment: .trailing)
                .foregroundColor(.white)
            
            ButtonStaticIcon(size: 20, imgName: "backward.fill") { viewModel.onClick() }
        }
    }
}

struct PenToolRewindButton_Previews: PreviewProvider {
    static var previews: some View {
        PenToolRewindButton()
    }
}
