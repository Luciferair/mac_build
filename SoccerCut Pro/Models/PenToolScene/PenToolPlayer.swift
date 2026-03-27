//
//  PenToolPlayer.swift
//  SoccerCut Pro
//
//  Created by Naoki Tanaka on 2023/08/30.
//

import AVFoundation

class PenToolPlayer: AVPlayer {
    private var playerItemForRestore: AVPlayerItem?
    private(set) var fileUrl: URL!
    private(set) var fps: Int32!
    
    var playingState: PlayingState { return PlayingState(rawValue: rate)! }
    var isPlaying: Bool { return playingState != .pause && error == nil }
    var currentTime: CMTime { return currentItem?.currentTime() ?? .zero }
    var duration: CMTime? { return currentItem?.duration }
    var resolution: CGSize { // TODO 複数解像度が1動画ファイル内に混在している場合は非サポートとしてポップアップを出した方がよいかもしれない
        guard let currentItem = currentItem else { return .zero }
        
        var maxResolution: CGSize = .zero
        for track in currentItem.tracks {
            guard let assetTrack = track.assetTrack else { continue }
            if maxResolution.width < assetTrack.naturalSize.width { maxResolution.width = assetTrack.naturalSize.width }
            if maxResolution.height < assetTrack.naturalSize.height { maxResolution.height = assetTrack.naturalSize.height }
        }
        
        return maxResolution
    }
    
    override init(url: URL) {
        super.init(url: url)
        
        fileUrl = url
        let asset = currentItem!.asset
        let tracks = asset.tracks(withMediaType: .video)
        fps = Int32(round(tracks.first!.nominalFrameRate))
        
        initialize()
    }
    override init() {
        super.init()
        initialize()
    }
    override init(playerItem: AVPlayerItem?) {
        super.init(playerItem: playerItem)
        initialize()
    }
    
    func initialize() {
        playerItemForRestore = currentItem
        preventsDisplaySleepDuringVideoPlayback = true
    }
    
    func restoreCurrentPlayerItem() { replaceCurrentItem(with: playerItemForRestore) }
        
    func togglePlayPause() { isPlaying ? pause() : play() }
    func skip(rate: Float? = nil) { self.rate = rate ?? playingState.rateIfSkip }
    func rewind(rate: Float? = nil) { self.rate = rate ?? playingState.rateIfRewind }
    
    func step(_ stepWidth: Int) { currentItem?.step(byCount: stepWidth) }
    
    func seekTo(_ seconds: Double) {
        let time = CMTime(seconds: seconds, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        seek(to: time, toleranceBefore: .zero, toleranceAfter: .zero, completionHandler: { _ in })
    }
    func seekBy(_ secsDiff: Double) {
        if duration == nil { return }

        var seconds = currentTime().seconds + secsDiff
        if seconds < 0 { seconds = 0 }
        if seconds > duration!.seconds { seconds = duration!.seconds }

        seekTo(seconds)
    }
    func seek5SecsForward() { seekBy(5) }
    func seek5SecsBackward() { seekBy(-5) }
    func stepForward() { step(1) }
    func stepBackward() { step(-1) }
}
