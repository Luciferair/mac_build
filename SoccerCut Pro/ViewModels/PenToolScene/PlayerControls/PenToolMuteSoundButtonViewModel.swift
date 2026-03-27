//
//  PenToolMuteSoundButtonViewModel.swift
//  SoccerCut Pro
//
//  Created by Naoki Tanaka on 2023/09/01.
//

import AVFoundation
import Cocoa
import SwiftUI

class PenToolMuteSoundButtonViewModel: ObservableObject {
    private let player: PenToolPlayer
    @Published var imgName: String = "speaker.wave.2.fill"
    
    init() {
        player = PenToolModel.now.player
        
        // 定期実行
        let timeInterval = 0.2
        Timer.scheduledTimer(withTimeInterval: timeInterval, repeats: true, block: { (timer) in
            self.imgName = (self.player.isMuted || self.player.volume == 0)  ? "speaker.slash.fill" : "speaker.wave.2.fill"
        })
    }
    
    func onClick() { player.isMuted.toggle() }
}
