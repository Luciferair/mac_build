//
//  PenToolEffectThumbnailView.swift
//  SoccerCut Pro
//
//  Created by Naoki Tanaka on 2023/09/30.
//

import SwiftUI

struct PenToolEffectThumbnailView: View, Identifiable {
    @ObservedObject private(set) var viewModel: PenToolEffectThumbnailViewModel
    
    let id = UUID()
    let frameSecs: Double
    let thumbnail: CGImage
    
    init(frameSecs: Double, thumbnail: CGImage) {
        self.frameSecs = frameSecs
        self.thumbnail = thumbnail
        viewModel = PenToolEffectThumbnailViewModel(frameSecs: frameSecs, thumbnail: thumbnail)
    }
    
    var click: some Gesture {
        TapGesture(count: 1)
            .onEnded { _ in
                viewModel.jumpToThisFrame()
            }
    }
        
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text(Int(viewModel.frameSecs).formatToHHMMSS()!)
                Spacer()
                Text("\(String(format: "%.1f", viewModel.effectFrozenSecs))秒間")
            }
            
            ZStack {
                Image(viewModel.thumbnail, scale: viewModel.thumbnailScale, label: Text(String(viewModel.frameSecs)))
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .gesture(click)
                
                // 追加ずみのPathの描画
                ForEach(viewModel.drawnPaths) { path in
                    path
                        .scaleEffect(viewModel.resolutionToThumbnailSizeRatio, anchor: .topLeading)
                }

                // ドラッグ中のpathの描画
                if let path = viewModel.drawingPath {
                    path
                        .scaleEffect(viewModel.resolutionToThumbnailSizeRatio, anchor: .topLeading)
                }
            }
            .clipped()
            
        }
    }
}

struct PenToolEffectThumbnailView_Previews: PreviewProvider {
    static var previews: some View {
        EmptyView()
    }
}
