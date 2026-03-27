//
//  VolumeSlider.swift
//  SoccerCut Pro
//
//  Created by Naoki Tanaka on 2023/06/02.
//

import SwiftUI

struct VolumeSlider: View {
    private var playerView: PlayerView!
    @ObservedObject var playerViewModel: PlayerViewModel
    @State private var isEditing: Bool = false
    @State private var currentValue: Double = 0
    
    init(playerViewModel: PlayerViewModel) {
        self.playerViewModel = playerViewModel
    }
    
    var body: some View {
        Slider(value: Binding(
                    get: { () -> Double in  // シークバーのつまみの現在値
                        if playerViewModel.isMuted { return 0 }
                        return isEditing ? currentValue : playerViewModel.volume
                    },
                    set: { newValue in // シークバー操作をPlayerに伝える際の値
                        playerViewModel.onSlideVolumeSlider(newValue: newValue)
                        currentValue = newValue
                    }),
               onEditingChanged: { hasStartMouseDown in
                    isEditing = hasStartMouseDown
        })
        .frame(width: 80)
    }
}

struct VolumeSlider_Previews: PreviewProvider {
    static var previews: some View {
        VolumeSlider(playerViewModel: PlayerViewModel())
    }
}
