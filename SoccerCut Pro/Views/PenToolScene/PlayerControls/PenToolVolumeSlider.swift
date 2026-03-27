//
//  PenToolVolumeSlider.swift
//  SoccerCut Pro
//
//  Created by Naoki Tanaka on 2023/09/01.
//

import SwiftUI

struct PenToolVolumeSlider: View {
    @ObservedObject var viewModel = PenToolVolumeSliderViewModel()
    @State private var isEditing: Bool = false
    @State private var currentValue: Double = 0
    
    var body: some View {
        Slider(value: Binding(
                    get: { () -> Double in  // シークバーのつまみの現在値
                        if viewModel.isMuted { return 0 }
                        return isEditing ? currentValue : viewModel.volume
                    },
                    set: { newValue in // シークバー操作をPlayerに伝える際の値
                        viewModel.onChangeValue(newValue: newValue)
                        currentValue = newValue
                    }),
               onEditingChanged: { hasStartMouseDown in
                    isEditing = hasStartMouseDown
        })
        .frame(width: 80)
    }
}

struct PenToolVolumeSlider_Previews: PreviewProvider {
    static var previews: some View {
        PenToolVolumeSlider()
    }
}
