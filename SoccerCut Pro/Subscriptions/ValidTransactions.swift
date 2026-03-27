//
//  ValidTransactions.swift
//  SoccerCut Pro
//
//  Created by Naoki Tanaka on 2023/06/17.
//

import Foundation
import StoreKit

struct ValidTransactions {
    static var instance: ValidTransactions = ValidTransactions()
    
    private var list: [Transaction] = []
    
    var purchaseDates: [Date] {
        get {
            var dates: [Date] = []
            for transaction in list {
                dates.append(transaction.purchaseDate)
            }
            return dates
        }
    }
    
    var purchaseProductIds: [String] {
        get {
            var productIDs: [String] = []
            for transaction in list {
                productIDs.append(transaction.productID)
            }
            return productIDs
        }
    }
    
    func observeUpdates() {
        Task(priority: .background) {
            // バックグラウンドでTransactionの変化を監視し続け、変化があればfor文が実行される
            for await verificationResult in Transaction.updates {
                guard case .verified(let transaction) = verificationResult else { continue }
                
                // 購入チェック
                PurchaseChecker.checkPurchases(purchasedDates: [transaction.purchaseDate], productIDs: [transaction.productID])
                // 購入アイテムが見えることを確認した時に行う処理
                await transaction.finish()
                // 一旦ウィンドウを非アクティブにして、アクティブになった時の処理(AppDelegate.applicationWillBecomeActive)に任せる
                await NSApplication.shared.hide(nil)
            }
        }
    }
        
    // 有効なTransaction一覧を取得
    mutating func fetch() async {
        list = []
        for await validationResult in Transaction.currentEntitlements {
            if case .verified(let transaction) = validationResult,
               transaction.productType == .autoRenewable { // && !transaction.isUpgraded { -> アップグレードしてようがしていまいがisEligibleであることに変わりないのでは
                list.append(transaction)
            }
        }
    }
    
    // 有効なサブスクリプションがあるか確認
    func containsAnyProductId() -> Bool {
        if (!isSubscriptionApp()) { return true } // 買い切りアプリは常にtrue
        
        return containsOneOfProductIds(ProductId.allCases)
    }
    
    func containsOneOfProductIds(_ productIds: [ProductId]) -> Bool {
        if (!isSubscriptionApp()) { return true } // 買い切りアプリは常にtrue
        
        for productId in productIds {
            let containsValidSubscription = list.contains(where: { $0.productID == productId.rawValue })
            if containsValidSubscription { return true }
        }
        return false
    }
    
    func isEligibleFor(appMode: ApplicationMode) -> Bool {
        var requiredProductIds: [ProductId]
        switch appMode {
        case .player:
            requiredProductIds = ProductId.playerAvailableIdList
            break
        case .penTool:
            requiredProductIds = ProductId.penToolAvailableIdList
            break
        }
        
        return containsOneOfProductIds(requiredProductIds)
    }
    
    func isSubscriptionApp() -> Bool
    {
        let isSubscriptionStr = Bundle.main.object(forInfoDictionaryKey: "IS_SUBSCRIPTION") as? String
        return isSubscriptionStr == "YES"
    }
}
