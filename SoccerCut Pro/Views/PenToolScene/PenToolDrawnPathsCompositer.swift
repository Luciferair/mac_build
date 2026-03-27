//
//  PenToolDrawnPathsCompositer.swift
//  SoccerCut Pro
//
//  Created by Naoki Tanaka on 2023/10/02.
//

import SwiftUI

struct PenToolDrawnPathsCompositer: View {
    @ObservedObject private(set) var viewModel: PenToolDrawnPathsCompositerViewModel
    
    init(paths: [PenToolDrawnPath], resolution: CGSize) {
        viewModel = PenToolDrawnPathsCompositerViewModel(paths: paths, resolution: resolution)
    }
    
    var body: some View {
        ZStack {
            Rectangle()
                .foregroundColor(.clear)
                .contentShape(Rectangle())
                .frame(width: viewModel.resolution.width, height: viewModel.resolution.height)
            
            ForEach(viewModel.paths) { path in
                path
            }
        }
    }
}

struct PenToolDrawnPathsCompositer_Previews: PreviewProvider {
    static var previews: some View {
        EmptyView()
    }
}
