//
//  PenToolRewindButtonViewModel.swift
//  SoccerCut Pro
//
//  Created by Naoki Tanaka on 2023/09/01.
//

import AVFoundation
import Cocoa
import SwiftUI

class PenToolRewindButtonViewModel: ObservableObject {
    private let player: PenToolPlayer
    @Published private(set) var label: String = ""
    
    init() {
        player = PenToolModel.now.player
        
        // rate変更検知
        NotificationCenter.default.addObserver(self, selector: #selector(self.onChangeRate),
                                               name: AVPlayer.rateDidChangeNotification,
                                               object: player)
    }
    
    func onClick() { player.rewind() }
    
    @objc func onChangeRate() { label = player.playingState.rewindLabel }
}
