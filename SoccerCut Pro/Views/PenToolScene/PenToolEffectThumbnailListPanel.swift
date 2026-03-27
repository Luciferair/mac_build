//
//  PenToolEffectListPanel.swift
//  SoccerCut Pro
//
//  Created by Naoki Tanaka on 2023/07/28.
//

import SwiftUI

struct PenToolEffectThumbnailListPanel: View {
    @ObservedObject private(set) var viewModel = PenToolEffectThumbnailListViewModel()
    
    static let effectListPanelWidth: CGFloat = 200
    
    var body: some View {
        List(viewModel.thumbnailViews) { thumbnailView in
            thumbnailView
            Divider()
        }
    }
}

struct EffectFrameListPanel_Previews: PreviewProvider {
    static var previews: some View {
        PenToolEffectThumbnailListPanel()
    }
}
