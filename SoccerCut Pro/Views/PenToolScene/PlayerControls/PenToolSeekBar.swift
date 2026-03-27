//
//  PenToolSeekBar.swift
//  SoccerCut Pro
//
//  Created by Naoki Tanaka on 2023/09/01.
//

import SwiftUI

struct PenToolSeekBar: View {
    @ObservedObject var viewModel = PenToolSeekBarViewModel()
    @State private var isEditing: Bool = false
    @State private var currentValue: Double = 0
    
    var body: some View {
        Slider(value: Binding(
                    get: { // シークバーのつまみの現在値
                        isEditing ? currentValue : viewModel.currentSecs
                    },
                    set: { newValue in // シークバー操作をPlayerに伝える際の値
                        viewModel.onChangeValue(newValue: newValue)
                        currentValue = newValue
                }),
              in: 0...viewModel.durationSecs) {
            // Label: do nothing
        } minimumValueLabel: {
            Text(isEditing ? Int(currentValue).formatToHHMMSS()! : viewModel.currentTimeLabel)
                .foregroundColor(.white)
                .font(.system(size: 16))
                .frame(width: 80, height: 24)
        } maximumValueLabel: {
            // 動画の総時間はシークバー操作中に変わることは無いのでPublisherだけを参照
            Text(viewModel.durationLabel)
                .foregroundColor(.white)
                .font(.system(size: 16))
                .frame(width: 80, height: 24)
        } onEditingChanged: { hasStartMouseDown in
            isEditing = hasStartMouseDown
        }
    }
}

struct PenToolSeekBar_Previews: PreviewProvider {
    static var previews: some View {
        PenToolSeekBar()
    }
}
