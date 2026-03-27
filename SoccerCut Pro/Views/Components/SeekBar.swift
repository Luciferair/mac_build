//
//  SeekBar.swift
//  SoccerCut Pro
//
//  Created by Naoki Tanaka on 2023/05/29.
//

import SwiftUI

struct SeekBar: View {
    @ObservedObject var playerViewModel: PlayerViewModel
    @State private var isEditing: Bool = false
    @State private var currentValue: Double = 0
    
    init(playerViewModel: PlayerViewModel) {
        self.playerViewModel = playerViewModel
    }
    
    var body: some View {
        Slider(value: Binding(
                    get: { // シークバーのつまみの現在値
                        isEditing ? currentValue : playerViewModel.currentSecs
                    },
                    set: { newValue in // シークバー操作をPlayerに伝える際の値
                        playerViewModel.onSlideSeekBar(newValue: newValue)
                        currentValue = newValue
                }),
              in: 0...playerViewModel.durationSecs) {
            // Label: do nothing
        } minimumValueLabel: {
            Text(isEditing ? Int(currentValue).formatToHHMMSS()! : playerViewModel.currentTimeLabel)
                .foregroundColor(.white)
                .font(.system(size: 16))
                .frame(width: 80, height: 24)
        } maximumValueLabel: {
            // 動画の総時間はシークバー操作中に変わることは無いのでPublisherだけを参照
            Text(playerViewModel.durationLabel)
                .foregroundColor(.white)
                .font(.system(size: 16))
                .frame(width: 80, height: 24)
        } onEditingChanged: { hasStartMouseDown in
            isEditing = hasStartMouseDown
        }
    }
}

struct SeekBar_Previews: PreviewProvider {
    static var previews: some View {
        SeekBar(playerViewModel: PlayerViewModel())
    }
}
