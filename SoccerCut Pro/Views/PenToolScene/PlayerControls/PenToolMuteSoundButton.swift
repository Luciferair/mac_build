//
//  PenToolMuteSoundButton.swift
//  SoccerCut Pro
//
//  Created by Naoki Tanaka on 2023/09/01.
//

import SwiftUI

struct PenToolMuteSoundButton: View {
    @ObservedObject private var viewModel = PenToolMuteSoundButtonViewModel()
    
    var body: some View {
        ButtonDynamicIcon(size: 20, imgName: $viewModel.imgName) { viewModel.onClick() }
    }
}

struct PenToolMuteSoundButton_Previews: PreviewProvider {
    static var previews: some View {
        PenToolMuteSoundButton()
    }
}
