//
//  PenToolPlayPauseButton.swift
//  SoccerCut Pro
//
//  Created by Naoki Tanaka on 2023/09/01.
//

import SwiftUI

struct PenToolPlayPauseButton: View {
    @ObservedObject private var viewModel = PenToolPlayPauseButtonViewModel()
    
    var body: some View {
        ButtonDynamicIcon(size: 30, imgName: $viewModel.imgName) { viewModel.onClick() }
    }
}

struct PenToolPlayPauseButton_Previews: PreviewProvider {
    static var previews: some View {
        PenToolPlayPauseButton()
    }
}
