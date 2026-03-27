//
//  PenToolSeekBarViewModel.swift
//  SoccerCut Pro
//
//  Created by Naoki Tanaka on 2023/09/01.
//

import AVFoundation
import Cocoa
import SwiftUI

class PenToolSeekBarViewModel: ObservableObject {
    private let player: PenToolPlayer
    @Published private(set) var durationSecs: Double = 0
    @Published private(set) var currentSecs: Double = 0
    @Published private(set) var durationLabel: String = "00:00:00"
    @Published private(set) var currentTimeLabel: String = "00:00:00"
    
    init() {
        player = PenToolModel.now.player
        
        // 定期実行
        let timeInterval = 0.2
        Timer.scheduledTimer(withTimeInterval: timeInterval, repeats: true, block: { (timer) in
            self.durationSecs = self.player.duration?.seconds ?? 0
            self.currentSecs = self.player.currentTime().seconds
            self.durationLabel = Int(self.durationSecs).formatToHHMMSS()!
            self.currentTimeLabel = Int(self.currentSecs).formatToHHMMSS()!
        })
    }
    
    func onChangeValue(newValue: Double) { player.seekTo(newValue) }
}
