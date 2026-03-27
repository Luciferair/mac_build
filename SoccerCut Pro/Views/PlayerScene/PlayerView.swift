//
//  PlayerView.swift
//  SoccerCut Pro
//
//  Created by Naoki Tanaka on 2023/05/22.
//

import AVKit
import Cocoa
import SwiftUI

class PlayerView: XibFilesOwnerView {
    private(set) var side: ScreenSides!
    private(set) var playersView: PlayersView!
    private(set) var playerViewModel: PlayerViewModel!
    var playerLayer: AVPlayerLayer?
    private(set) var controlsHV: NSHostingView<PlayerControlsView>?
    private(set) var processingView: ProcessingView!
    
    @IBOutlet weak var playerBtn: NSButton!
    @IBOutlet weak var penToolBtn: NSButton!
    @IBOutlet weak var tutorialBtn: NSButton!
    @IBOutlet weak var reviewBtn: NSButton!
    @IBOutlet weak var subscriptionBtn: NSButton!
    
    var player: AVPlayer? { playerLayer?.player }
    var isPlaying: Bool { player != nil && playingState != .pause && player?.error == nil }
    var playingState: PlayingState {
        guard let player = self.player else { return .pause }
        return PlayingState(rawValue: player.rate) ?? .pause
    }
    var duration: CMTime? { player?.currentItem?.duration }
    var currentTime: CMTime? { player?.currentTime() }
    var isMuted: Bool { player == nil || player!.isMuted }
    var volume: Float { player != nil ? player!.volume : 0 }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
        
    func initialize(side: ScreenSides, playersView: PlayersView, playerViewModel: PlayerViewModel, processingView: ProcessingView) {
        self.side = side
        self.playersView = playersView
        self.playerViewModel = playerViewModel
        self.processingView = processingView
        controlsHV = self.addSwiftUIView(PlayerControlsView(playerViewModel: playerViewModel))
    }
    
    func openSelectFilePanel(appMode: ApplicationMode) {
        // サブスクの有無確認
        if !ValidTransactions.instance.isEligibleFor(appMode: appMode) {
            // サブスクリプションライセンスが無いので選択画面を表示
            Products.instance.selection()
            return
        }
        
        let openPanel = NSOpenPanel()
        
        if #available(macOS 11.0, *) {
            openPanel.allowedContentTypes = [.movie]
        } else {
            openPanel.allowedFileTypes = ["movie"]
        }
        openPanel.allowsMultipleSelection = false
        
        let modalResponse = openPanel.runModal()
        if modalResponse == .OK {
            guard let url = openPanel.url else { return }
            switch appMode{
            case .player:
                onSelectFile(url: url)
                break
            case .penTool:
                // ペンツールウィンドウを開く
                let storyboard = NSStoryboard(name: "Main", bundle: nil)
                if let windowController = storyboard.instantiateController(withIdentifier: "PenToolWindowID") as? NSWindowController {
                    PenToolViewController.fileUrl = url
                    windowController.showWindow(self)
                }
                break
            }
        }
    }
    
    func onSelectFile(url: URL) {
        playerViewModel.onSelectFile(url: url)
        
        playerLayer = AVPlayerLayer(player: playerViewModel.player)
        playerLayer!.videoGravity = .resizeAspect

        wantsLayer = true
        layer?.addSublayer(playerLayer!)
        makeLayerAndItsSublayersTheSameFrameAsMe()
        
        playerBtn.isHidden = true
        penToolBtn.isHidden = true
        tutorialBtn.isHidden = true
        reviewBtn.isHidden = true
        subscriptionBtn.isHidden = true
        
        self.playersView.prepareDefaultScreens(loadedSide: side)
    }
    
    func showTrimmingMarker() {
        playerViewModel.onShowTrimmingMarker()
    }
    
    func openSaveFilePanel() {
        guard let urlFrom = playerViewModel.fileURL else { return }
        if playerViewModel.playerModel.trimmingStartSecs == nil { return }
        
        // Bug②: pause and freeze end point BEFORE the save dialog opens
        playerViewModel.playerModel.pause()
        playerViewModel.playerModel.setTrimmingEnd()
        
        // 保存先URLをポップアップで取得
        let savePanel = NSSavePanel()
        if #available(macOS 11.0, *) {
            savePanel.allowedContentTypes = [.movie]
        } else {
            savePanel.allowedFileTypes = ["movie"]
        }
        savePanel.isExtensionHidden = false
        let dt = Date()
        let df = DateFormatter()
        df.dateFormat = "yyyyMMdd_HHmmss"
        savePanel.nameFieldStringValue = urlFrom.getFilenameWith(suffix: df.string(from: dt), removeExtension: false)
        
        AppDelegate.instance.switchPlayerStepAndSkipRewind(isEnabled: false)
        let modalResponse = savePanel.runModal()
        AppDelegate.instance.switchPlayerStepAndSkipRewind(isEnabled: true)
        
        if modalResponse == .OK {
            guard let exportUrl = savePanel.url else { return }
            // 保存中画面表示
            processingView.show()
            // トリミング実行
            self.playerViewModel.onSelectPathForSavingTrimmedFile(exportUrl: exportUrl)            
            // トリミング結果をポーリング
            let timeInterval = 1.0
            Timer.scheduledTimer(withTimeInterval: timeInterval, repeats: true, block: { (timer) in
                if self.playerViewModel.isExecutingTrimming { return }
                
                // トリミング結果表示
                self.processingView.waitForClick(errorMsg: self.playerViewModel.trimmingErrorMsg,
                                                 statusCode: self.playerViewModel.trimmingStatus)
                
                // レビュー依頼関連処理
                if self.playerViewModel.trimmingStatus == .completed {
                    SaveCounterForReview.incrementAndRequestReview()
                }
                
                timer.invalidate()
            })
        }
    }
    
    func showScreenSingle() {
        isHidden = false

        frame = superview!.frame
        playerViewModel.viewFrame = frame
        playerViewModel.updateLastlyActivatedViewTime()
        
        controlsHV?.setFrameSize(bounds.size)
        subviews.first!.frame = CGRect(origin: .zero, size: bounds.size)
        
        makeLayerAndItsSublayersTheSameFrameAsMe()
    }
    
    func showScreenDual() {
        isHidden = false
        
        let playersViewSize = superview!.frame.size
        frame.origin = side == .left ? .zero : CGPoint(x: playersViewSize.width/2, y: 0)
        frame.size = CGSize(width: playersViewSize.width/2, height: playersViewSize.height)
        playerViewModel.viewFrame = frame

        controlsHV?.setFrameSize(bounds.size)
        subviews.first!.frame = CGRect(origin: .zero, size: bounds.size)
                
        makeLayerAndItsSublayersTheSameFrameAsMe()
    }
    
    func hideScreen() {
        isHidden = true
    }
    
    @IBAction func clickPlayerBtn(_ sender: NSButton) {
        openSelectFilePanel(appMode: .player)
    }
    
    @IBAction func clickPenToolBtn(_ sender: NSButton) {
        openSelectFilePanel(appMode: .penTool)
    }
    
    
    @IBAction func clickTutorialBtn(_ sender: NSButton) {
        if let url = URL(string: WebSiteURL.tutorialPage.rawValue) {
            NSWorkspace.shared.open(url)
        }
    }
    
    @IBAction func clickReviewBtn(_ sender: NSButton) {
        if let url = URL(string: WebSiteURL.reviewPage.rawValue) {
            NSWorkspace.shared.open(url)
        }
    }
    
    @IBAction func clickSubscriptionBtn(_ sender: NSButton) {
        Products.instance.selection()
    }
    
    func onResizeWindow(isDual: Bool) {
        if isHidden { return }
        isDual ? showScreenDual() : showScreenSingle()
    }
}
