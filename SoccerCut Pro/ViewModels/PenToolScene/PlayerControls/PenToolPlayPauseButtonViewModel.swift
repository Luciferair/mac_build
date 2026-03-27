//
//  PenToolPlayPauseButtonViewModel.swift
//  SoccerCut Pro
//
//  Created by Naoki Tanaka on 2023/09/01.
//

import AVFoundation
import Cocoa
import SwiftUI

class PenToolPlayPauseButtonViewModel: ObservableObject {
    private let player: PenToolPlayer
    @Published var imgName: String = "play.fill"
    
    init() {
        player = PenToolModel.now.player
        
        // rate変更検知
        NotificationCenter.default.addObserver(self, selector: #selector(self.onChangeRate),
                                               name: AVPlayer.rateDidChangeNotification,
                                               object: player)
    }
    
    func onClick() { player.togglePlayPause() }
    
    @objc func onChangeRate() { imgName = player.isPlaying ? "pause.fill" : "play.fill" }
}
