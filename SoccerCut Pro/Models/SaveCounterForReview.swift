//
//  SaveCounterForReview.swift
//  SoccerCut Pro
//
//  Created by Naoki Tanaka on 2023/10/28.
//

import StoreKit

class SaveCounterForReview {
    private static let saveCountKey = "movieSaveCount"
    private static let firstSaveDateKey = "firstSaveDate"
    private static let userDefaults = UserDefaults()
    
    static func incrementAndRequestReview() {
        userDefaults.setValue((userDefaults.integer(forKey: saveCountKey))+1, forKey: saveCountKey)
        if userDefaults.object(forKey: firstSaveDateKey) == nil { userDefaults.setValue(Date(), forKey: firstSaveDateKey) }
        userDefaults.synchronize()
        
        let count = userDefaults.integer(forKey: saveCountKey)
        
        let now = Date()
        let firstSaveDate = userDefaults.object(forKey: firstSaveDateKey) as? Date
        let after2Weeks = Calendar.current.date(byAdding: .day, value: 14, to: firstSaveDate ?? now) ?? now
        let after2Months = Calendar.current.date(byAdding: .day, value: 60, to: firstSaveDate ?? now) ?? now
        
        // レビュー依頼ポップアップはやはり不要とのことなのでコメントアウト
        // if count == 3 || now > after2Weeks || now > after2Months { SKStoreReviewController.requestReview() }
    }
    
}
