//
//  Notification+Name.swift
//  SoccerCut Pro
//
//  Created by Naoki Tanaka on 2023/08/18.
//

import Cocoa

extension Notification.Name {
    static let clickedDrawnPathNotification = Notification.Name("clickedDrawnPathNotification")
    static let drawnPathDidChangeNotification = Notification.Name("drawnPathDidChangeNotification")
    static let thumbnailDidChangeNotification = Notification.Name("thumbnailDidChangeNotification")
    static let processingStateDidChangeNotification = Notification.Name("processingStateDidChangeNotification")
}
