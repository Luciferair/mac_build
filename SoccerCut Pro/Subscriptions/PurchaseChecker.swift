//
//  PurchaseChecker.swift
//  SoccerCut Pro
//
//  Created by Naoki Tanaka on 2023/11/06.
//

import Cocoa

class PurchaseChecker {
    private static let prevPurchaseCheckedDateKey = "prevPurchaseCheckedDate"
    
    static func checkPurchases(purchasedDates: [Date], productIDs: [String]) {
        guard let prevPurchaseCheckedDate = UserDefaults.standard.object(forKey: prevPurchaseCheckedDateKey) as? Date else {
            UserDefaults.standard.setValue(Date(), forKey: prevPurchaseCheckedDateKey)
            return
        }
        
        UserDefaults.standard.setValue(Date(), forKey: prevPurchaseCheckedDateKey)
    }
}
