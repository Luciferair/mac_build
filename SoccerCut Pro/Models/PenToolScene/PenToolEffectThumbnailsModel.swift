//
//  PenToolEffectThumbnails.swift
//  SoccerCut Pro
//
//  Created by Naoki Tanaka on 2023/10/02.
//

import AVFoundation

class PenToolEffectThumbnailsModel {
    let player: PenToolPlayer
    let pathHistory: PenToolPathHistory
    private(set) var list: [PenToolEffectThumbnailView] = []
        
    init(player: PenToolPlayer, pathHistory: PenToolPathHistory) {
        self.player = player
        self.pathHistory = pathHistory
        NotificationCenter.default.addObserver(self, selector: #selector(self.updateList), name: .drawnPathDidChangeNotification, object: self.pathHistory)
    }
    
    @objc func updateList(notification: NSNotification?) {
        guard let targetFrame = notification?.userInfo?["targetFrame"] as? CMTime else { return }

        // 描画無しならサムネイルも削除
        if pathHistory.currentTargetFrameDrawns.isEmpty {
            list.removeAll(where: {$0.frameSecs == targetFrame.seconds})
            NotificationCenter.default.post(name: .thumbnailDidChangeNotification, object: self)
            return
        }
 
        // 既にサムネイルが存在するなら何もしない
        if list.contains(where: { $0.frameSecs == targetFrame.seconds }) { return }
        
        // サムネイル新規作成
        let asset = AVAsset(url: player.fileUrl)
        let generator = AVAssetImageGenerator(asset: asset)
        generator.appliesPreferredTrackTransform = true
        generator.requestedTimeToleranceAfter = .zero
        generator.requestedTimeToleranceBefore = .zero
        generator.apertureMode = .productionAperture

        Task { @MainActor in
            var thumbnail: CGImage?
            if #available(macOS 13.0, *) {
                thumbnail = try? await generator.image(at: targetFrame).image
            } else {
                thumbnail = try? generator.copyCGImage(at: targetFrame, actualTime: nil)
            }
            guard let thumbnail else { return }
            
            list.append(PenToolEffectThumbnailView(frameSecs: targetFrame.seconds, thumbnail: thumbnail))
            list.sort(by: {$0.frameSecs < $1.frameSecs})
            NotificationCenter.default.post(name: .thumbnailDidChangeNotification, object: self)
        }
    }
    
    func cgImage(at frameSecs: Double) -> CGImage? {
        return list.first(where: { $0.frameSecs == frameSecs })?.thumbnail
    }
}
