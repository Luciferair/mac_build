//
//  PenToolSceneRootView.swift
//  SoccerCut Pro
//
//  Created by Naoki Tanaka on 2023/07/28.
//

import Cocoa
import SwiftUI

class PenToolSceneRootView: NSView {
    private var viewModel: PenToolSceneRootViewModel!
    
    private var processingView: PenToolProcessingView!
    private(set) var playerScreen: PenToolPlayerView!
    private var canvasPanel: NSHostingView<PenToolCanvasPanel>!
    private var penToolTypePanel: NSHostingView<PenToolTypePanel>!
    private var penToolStylePanels: Dictionary<PenToolType, NSHostingView<PenToolStylePanelPerType>> = [:]
    private var effectListPanel: NSHostingView<PenToolEffectThumbnailListPanel>!
    private var editPanel: NSHostingView<PenToolEditPanel>!
    private var playerControlsPanel: NSHostingView<PenToolPlayerControlsPanel>!
    
    private var penToolType: PenToolType = .arrow
    
    func initialize(processingView: PenToolProcessingView) {
        viewModel = PenToolSceneRootViewModel()
        
        // 各UIの生成
        canvasPanel = addSwiftUIView(PenToolCanvasPanel())
        penToolTypePanel = addSwiftUIView(PenToolTypePanel())
        for type in PenToolType.allCases {
            let penToolStylePanel = addSwiftUIView(PenToolStylePanelPerType(type: type))
            penToolStylePanels[type] = penToolStylePanel
        }
        effectListPanel = addSwiftUIView(PenToolEffectThumbnailListPanel())
        editPanel = addSwiftUIView(PenToolEditPanel())
        playerControlsPanel = addSwiftUIView(PenToolPlayerControlsPanel())
        
        playerScreen = subviews[0] as? PenToolPlayerView
        playerScreen.initialize(controlsHV: playerControlsPanel)
        
        self.processingView = processingView
        self.processingView.hide()

        // ウィンドウサイズ変更検知
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(layOutViews),
                                               name: NSView.frameDidChangeNotification,
                                               object: nil)
        
        // ProcessingViewState変更検知
        var timeInterval = 0.5
        Timer.scheduledTimer(withTimeInterval: timeInterval, repeats: true, block: { (timer) in
            guard let changedProcessingViewState = self.viewModel.changedProcessingViewState else { return }
            
            switch(changedProcessingViewState) {
            case .none:
                for subview in self.subviews {
                    subview.isHidden = false
                }
                self.processingView.hide()
                break
                
            case .indicator:
                for subview in self.subviews {
                    subview.isHidden = true
                }
                self.processingView.show(processType: self.viewModel.processType)
                break
                
            case .dialog:
                // 処理が早すぎて.indicatorを飛ばしてここにくる可能性があるので、その場合は.indicatorと同じ処理
                if self.processingView.isHidden {
                    for subview in self.subviews {
                        subview.isHidden = true
                    }
                    self.processingView.show(processType: self.viewModel.processType)
                }
                
                self.processingView.waitForClick(processType: self.viewModel.processType, errorMsg: self.viewModel.processingViewErrorMsg, statusCode: self.viewModel.processingViewStatusCode)
                
                // レビュー依頼関連処理
                if self.viewModel.processingViewStatusCode == .completed {
                    SaveCounterForReview.incrementAndRequestReview()
                }
                
                break
            }
            
            self.viewModel.resetChangedProcessingViewState()
        })
        
        // PenToolType変更検知
        timeInterval = 0.1
        Timer.scheduledTimer(withTimeInterval: timeInterval, repeats: true, block: { (timer) in
            if self.penToolType != self.viewModel.penToolType {
                NSColorPanel.shared.close() // 前のpenToolTypeのColorPickerモーダルが残っていると色が変更できないので閉じる
                self.penToolType = self.viewModel.penToolType
            }
        })
    }
    
    @objc func layOutViews() {
        guard let window else { return }
        
        let windowHeaderToolBarHeight: CGFloat = 30 // 自分で決める値ではなくウィンドウのタブ？バーの高さがだいたいこれくらい
        frame.origin = .zero
        frame.size = CGSize(width: window.frame.size.width, height: window.frame.size.height - windowHeaderToolBarHeight)
        
        let penToolTypePanelWidth: CGFloat = 40
        penToolTypePanel.frame.origin = .zero
        penToolTypePanel.frame.size = CGSize(width: penToolTypePanelWidth, height: frame.height)
        
        let penToolStylePanelWidth: CGFloat = 100
        for penToolStylePanel in penToolStylePanels.values {
            penToolStylePanel.frame.origin = CGPoint(x: penToolTypePanel.frame.width, y: 0)
            penToolStylePanel.frame.size = CGSize(width: penToolStylePanelWidth, height: frame.height)
        }
        
        let effectListPanelWidth = PenToolEffectThumbnailListPanel.effectListPanelWidth
        effectListPanel.frame.origin = CGPoint(x: frame.width - effectListPanelWidth, y: 0)
        effectListPanel.frame.size = CGSize(width: effectListPanelWidth, height: frame.height)
        
        let penToolPanelsWidth = penToolTypePanelWidth + penToolStylePanelWidth
        let playerControlsPanelHeight: CGFloat = 80
        playerControlsPanel.frame.origin = CGPoint(x: penToolPanelsWidth, y: frame.minY)
        playerControlsPanel.frame.size = CGSize(width: frame.width - penToolPanelsWidth - effectListPanelWidth, height: playerControlsPanelHeight)

        let editHistoryPanelHeight: CGFloat = 40
        editPanel.frame.origin = CGPoint(x: penToolPanelsWidth, y: frame.maxY - editHistoryPanelHeight)
        editPanel.frame.size = CGSize(width: playerControlsPanel.frame.width, height: editHistoryPanelHeight)
        
        playerScreen.frame.origin = CGPoint(x: penToolPanelsWidth, y: playerControlsPanel.frame.maxY)
        playerScreen.frame.size = CGSize(width: playerControlsPanel.frame.width,
                                         height: frame.height - playerControlsPanelHeight - editHistoryPanelHeight)

        playerScreen.makeLayerAndItsSublayersTheSameFrameAsMe()
        
        if let playerLayer = playerScreen.playerLayer, playerLayer.isReadyForDisplay {
            canvasPanel.frame.origin = playerLayer.videoRect.origin + playerScreen.frame.origin
            canvasPanel.frame.size = playerLayer.videoRect.size
            canvasPanel.rootView.onResize(origin: canvasPanel.frame.origin, newVideoRect: playerLayer.videoRect)
        } else {
            canvasPanel.frame.origin = CGPoint(x: playerScreen.frame.minX, y: 0)
            canvasPanel.frame.size = CGSize(width: playerScreen.frame.width, height: frame.height)
        }
    }
    
    func onClickOKInDialog() {
        viewModel.onClickOKInDialog()
    }
    
    func currentPenToolType() -> PenToolType {
        return viewModel.penToolType
    }
}
