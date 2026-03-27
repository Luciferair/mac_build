//
//  PenToolSceneRootViewModel.swift
//  SoccerCut Pro
//
//  Created by Naoki Tanaka on 2023/10/05.
//

import AVFoundation
import Cocoa
import SwiftUI

class PenToolSceneRootViewModel {
    private let processingStateHolder: PenToolProcessingViewStateHolder
    private let pathFactory: PenToolPathFactory
    private(set) var changedProcessingViewState: ProcessingViewState? = nil
    private(set) var processType: ProcessType = .none
    private(set) var penToolType: PenToolType = .arrow
    
    var processingViewErrorMsg: String? { return processingStateHolder.errorMsg }
    var processingViewStatusCode: AVAssetExportSession.Status? { return processingStateHolder.statusCode }
    
    init() {
        processingStateHolder = PenToolModel.now.processingStateHolder
        pathFactory = PenToolModel.now.pathFactory
        NotificationCenter.default.addObserver(self, selector: #selector(self.changeProcessingView), name: .processingStateDidChangeNotification, object: processingStateHolder)
        
        // PenToolType変更検知
        let timeInterval = 0.1
        Timer.scheduledTimer(withTimeInterval: timeInterval, repeats: true, block: { (timer) in
            self.penToolType = self.pathFactory.currentType
        })
    }
    
    @objc func changeProcessingView() {
        changedProcessingViewState = processingStateHolder.current
        processType = processingStateHolder.processType
    }

    func resetChangedProcessingViewState() {
        changedProcessingViewState = nil
        processType = .none
    }
    
    func onClickOKInDialog() {
        processingStateHolder.setCurrent(.none, processType: .none)
    }
}
