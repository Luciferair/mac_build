//
//  PenToolEffectListViewModel.swift
//  SoccerCut Pro
//
//  Created by Naoki Tanaka on 2023/09/23.
//

import AVFoundation
import Cocoa
import SwiftUI

class PenToolEffectThumbnailListViewModel: ObservableObject {
    private let player: PenToolPlayer
    private let thumbnailsModel: PenToolEffectThumbnailsModel

    @Published private(set) var thumbnailViews: [PenToolEffectThumbnailView] = []
    
    init() {
        player = PenToolModel.now.player
        thumbnailsModel = PenToolModel.now.effectThumbnails
        NotificationCenter.default.addObserver(self, selector: #selector(self.updateThumbnailViews), name: .thumbnailDidChangeNotification, object: thumbnailsModel)
    }

    @objc func updateThumbnailViews() {
        thumbnailViews = thumbnailsModel.list
    }
}
