//
//  ProcessType.swift
//  SoccerCut Pro
//
//  Created by Naoki Tanaka on 2023/10/24.
//

public enum ProcessType {
    case none
    case screenshot
    case preview
    case save
    
    var processName: String {
        switch self {
        case .none: return ""
        case .screenshot: return "スクリーンショットの保存"
        case .preview: return "プレビュー動画の生成"
        case .save: return "動画の保存"
        }
    }
}
