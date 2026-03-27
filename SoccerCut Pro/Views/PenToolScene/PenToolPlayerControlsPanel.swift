//
//  PenToolPlayerControlsPanel.swift
//  SoccerCut Pro
//
//  Created by Naoki Tanaka on 2023/08/30.
//

import SwiftUI

struct PenToolPlayerControlsPanel: View {    
    var body: some View {
        Group {
            VStack(spacing: 0) {

                ZStack {
                    // 音量調節ボタンとスライダー
                    HStack {
                        PenToolMuteSoundButton()
                        PenToolVolumeSlider()
                        Spacer()
                    }
                    
                    // 巻き戻し/再生・一時停止/早送り
                    HStack {
                        PenToolRewindButton()
                        PenToolPlayPauseButton()
                        PenToolSkipButton()
                    }
                }
                
                ZStack {
//                    // マーカー
//                    Triangle()
//                        .frame(width: 20, height: 20)
//                        .offset(x: viewModel.trimmingStartMarkerOffsetX, y: 0)
//                        .rotationEffect(Angle(degrees: 180))
//                        .foregroundColor(.orange)
//                        .opacity(viewModel.isShownTrimmingMarker ? 1.0 : 0.0)
                }
                
                PenToolSeekBar()
            }
            .padding(10)
            .background(.gray)
            .clipShape(RoundedRectangle(cornerRadius: 10))
        }
    }
}

struct PlayerControlsPanel_Previews: PreviewProvider {
    static var previews: some View {
        PenToolPlayerControlsPanel()
    }
}
