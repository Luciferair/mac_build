//
//  PenToolVolumeSliderViewModel.swift
//  SoccerCut Pro
//
//  Created by Naoki Tanaka on 2023/09/01.
//

import AVFoundation
import Cocoa
import SwiftUI

class PenToolVolumeSliderViewModel: ObservableObject {
    private let player: PenToolPlayer
    @Published var volume: Double = 1
    @Published var isMuted: Bool = false
    
    init() {
        player = PenToolModel.now.player
        
        // 定期実行
        let timeInterval = 0.2
        Timer.scheduledTimer(withTimeInterval: timeInterval, repeats: true, block: { (timer) in
            self.volume = Double(self.player.volume)
            self.isMuted = self.player.isMuted
        })
    }
    
    func onChangeValue(newValue: Double) { player.volume = Float(newValue) }
}
