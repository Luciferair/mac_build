//
//  ProductId.swift
//  SoccerCut Pro
//
//  Created by Naoki Tanaka on 2023/06/16.
//

import Foundation

enum ProductId: String, CaseIterable {
    // 製品IDにハイフンを指定できないのでSoccerCutとProの間のハイフンはアンダーバーに変換
    case basicMonthly = "blog.daichimatsumoto.SoccerCut_Pro.SoccerCut_Pro_Monthly"
    case basicYearly = "blog.daichimatsumoto.SoccerCut_Pro.SoccerCut_Pro_Yearly"
    case expertMonthly = "blog.daichimatsumoto.SoccerCut_Pro.SoccerCut_Pro_Expert_Monthly"
    case expertYearly = "blog.daichimatsumoto.SoccerCut_Pro.SoccerCut_Pro_Expert_Yearly"
    // 以下は使用しなくなったが、削除しても同じIDを二度と使えないので残しておく
    //    case editorMonthly = "blog.daichimatsumoto.SoccerCut_Pro.SoccerCut_Pro_Editor_Monthly"
    //    case editorYearly = "blog.daichimatsumoto.SoccerCut_Pro.SoccerCut_Pro_Editor_Yearly"
    
    static var allRawValues: [String] {
        var rawValues: [String] = []
        for productId in ProductId.allCases {
            rawValues.append(productId.rawValue)
        }
        
        return rawValues
    }
    
    static var playerAvailableIdList: [ProductId] {
        return [.basicMonthly, .basicYearly, .expertMonthly, .expertYearly]
    }
    
    static var penToolAvailableIdList: [ProductId] {
        return [.expertMonthly, .expertYearly]
    }
    
    var isFreeTrialAvailable: Bool {
        return self == .expertMonthly
    }
}
