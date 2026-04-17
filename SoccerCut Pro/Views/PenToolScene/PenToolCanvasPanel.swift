//
//  PenToolCanvasPanel.swift
//  SoccerCut Pro
//
//  Created by Naoki Tanaka on 2023/07/31.
//

import SwiftUI

struct PenToolCanvasPanel: View {
    @ObservedObject private(set) var viewModel = PenToolCanvasViewModel()
    @State private var isDrag = false
        
    func onResize(origin: CGPoint, newVideoRect: CGRect) {
        viewModel.resizePaths(canvasOrigin: origin, newVideoRect: newVideoRect)
    }
    
    var doubleClick: some Gesture {
        TapGesture(count: 2)
            .onEnded {
                viewModel.onDoubleClick()
            }
    }

    var drag: some Gesture {
        DragGesture(minimumDistance: 0)
            .onChanged { value in
                // ドラッグ開始を検知
                if !isDrag {
                    viewModel.onStartDrag()
                    isDrag = true
                }
                
                if value.location.x < 0 || value.location.y < 0
                    || viewModel.videoRect.width < value.location.x || viewModel.videoRect.height < value.location.y { return }
                viewModel.onDrag(startLocationInVideoRect: value.startLocation, locationInVideoRect: value.location, isEnd: false)
            }
            .onEnded { value in
                viewModel.onDrag(startLocationInVideoRect: value.startLocation, locationInVideoRect: value.location, isEnd: true)
                isDrag = false
            }
    }
    
    var body: some View {
        ZStack {
            // Canvas部分
            Rectangle()
                .foregroundColor(.clear)
                .contentShape(Rectangle())
                .gesture(doubleClick)
                .gesture(drag)
            
            // 追加ずみのPathの描画
            ForEach(viewModel.drawnPathsOnCurrentFrame) { path in
                path
                    .scaleEffect(viewModel.resolutionToVideoRectSizeRatio, anchor: .topLeading)
            }
            
            // ドラッグ中のpathの描画
            if let path = viewModel.drawingPathOnCurrentFrame {
                path
                    .scaleEffect(viewModel.resolutionToVideoRectSizeRatio, anchor: .topLeading)
            }
        }
        .clipped()
    }
}

struct CanvasPanel_Previews: PreviewProvider {
    static var previews: some View {
        EmptyView()
    }
}
