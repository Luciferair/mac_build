//
//  PenToolModel.swift
//  SoccerCut Pro
//
//  Created by Naoki Tanaka on 2023/09/01.
//

import Foundation

class PenToolModel {
    static var now: PenToolModel!
    
    private(set) var processingStateHolder: PenToolProcessingViewStateHolder
    private(set) var player: PenToolPlayer
    private(set) var pathHistory: PenToolPathHistory
    private(set) var pathFactory: PenToolPathFactory
    private(set) var effectThumbnails: PenToolEffectThumbnailsModel
    
    private init(fileUrl: URL) {
        processingStateHolder = PenToolProcessingViewStateHolder()
        player = PenToolPlayer(url: fileUrl)
        pathHistory = PenToolPathHistory(player: player)
        pathFactory = PenToolPathFactory(pathHistory: pathHistory)
        effectThumbnails = PenToolEffectThumbnailsModel(player: player, pathHistory: pathHistory)
    }
    
    static func initialize(fileUrl: URL) {
        PenToolModel.now = PenToolModel(fileUrl: fileUrl)
    }
}
