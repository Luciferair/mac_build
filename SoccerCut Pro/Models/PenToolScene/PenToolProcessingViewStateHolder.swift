//
//  PenToolProcessingViewStateHolder.swift
//  SoccerCut Pro
//
//  Created by Naoki Tanaka on 2023/10/03.
//

import AVFoundation
import Cocoa

class PenToolProcessingViewStateHolder {
    private(set) var current: ProcessingViewState = .none
    private(set) var processType: ProcessType = .none

    var errorMsg: String? = nil
    var statusCode: AVAssetExportSession.Status? = nil
    
    func setCurrent(_ state: ProcessingViewState, processType: ProcessType) {
        self.current = state
        self.processType = processType
        if current == .none {
            errorMsg = nil
            statusCode = nil
        }
        NotificationCenter.default.post(name: .processingStateDidChangeNotification, object: self)
    }
}
