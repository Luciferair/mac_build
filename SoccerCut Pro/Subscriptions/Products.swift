//
//  Products.swift
//  SoccerCut Pro
//
//  Created by Naoki Tanaka on 2023/06/17.
//

import Foundation
import StoreKit
import SwiftUI

struct Products {
    static var instance: Products = Products()

    private var list: [Product] = []
    private(set) var isEligibleForFreeTrial: Bool = false
            
    mutating func fetch() async throws {
        do {
            list = try await Product.products(for: ProductId.allRawValues)
        } catch {
            throw SubscriptionError.failedFetchingProductId
        }
        
        if list.isEmpty { throw SubscriptionError.productIdNotFound }
        
        let expertMonthlyProduct = list.first(where: { $0.id == ProductId.expertMonthly.rawValue })
        isEligibleForFreeTrial = await expertMonthlyProduct?.subscription?.isEligibleForIntroOffer ?? false
    }
    
    func find(productId: ProductId) -> Product? {
        return list.first(where: { $0.id == productId.rawValue })
    }
    
    func pricePerPeriodOf(productId: ProductId) -> String {
        let product = find(productId: productId)
        
        var period = ""
        if #available(macOS 12.3, *) {
            period = product?.subscription?.subscriptionPeriod.unit.localizedDescription ?? ""
        } else {
            period = productId.rawValue.contains("Monthly") ? "月" : "年"
        }
        
        return "\(product?.displayPrice ?? "")/\(period)"
    }
            
    // サブスクリプションの選択・購入を促すアラート表示
    func selection() {
        Task { @MainActor in
            // ユーザー操作を一旦禁止
            AppDelegate.setViewIsHidden(true)
            
            let alert = NSAlert()
            alert.messageText = "サブスクリプション登録"
            alert.informativeText = ""
            
            // アラート画面に追加する大元のViewなどのサイズ指定
            let accessoryView = NSView(frame: CGRect(x: 0, y: 0, width: 640, height: 400))
            let textViewHeight: CGFloat = 50
            let noteViewHeight: CGFloat = 50
            
            // プライバシーポリシー&利用規約View
            let textView = NSTextView(frame: CGRect(x: 0, y: accessoryView.frame.height-textViewHeight,
                                                    width: accessoryView.frame.width, height: textViewHeight))
            textView.string = "SoccerCut Proをご利用になるためには、プライバシーポリシーおよび利用規約に同意の上、\nサブスクリプション登録が必要です。"
            let privacyPolicyUrl = URL(string: WebSiteURL.privacyPolicyPage.rawValue)!
            let termsOfUseUrl = URL(string: WebSiteURL.termsOfUsePage.rawValue)!
            textView.textStorage?.addAttributes([.link: privacyPolicyUrl],
                                                range: NSString(string: textView.string).range(of: "プライバシーポリシー"))
            textView.textStorage?.addAttributes([.link: termsOfUseUrl],
                                                range: NSString(string: textView.string).range(of: "利用規約"))
            textView.drawsBackground = false
            textView.setAlignment(.center, range: NSRange(location: 0, length: textView.string.count))
            accessoryView.addSubview(textView)
            
            // 選択画面View
            let selectionView =  accessoryView.addSwiftUIView(ProductSelectionView(productList: list))
            selectionView.frame = CGRect(x: 0, y: noteViewHeight,
                                         width: accessoryView.frame.width, height: accessoryView.frame.height-textView.frame.height-noteViewHeight)
            
            // 注意書きView
            let noteView = NSTextView(frame: CGRect(x: 0, y: 0,
                                                    width: accessoryView.frame.width, height: noteViewHeight))
            noteView.string = "※ExpertはBasicのアップグレードであるため、\nExpert購入時Basicは自動的に解約されます。"
            noteView.drawsBackground = false
            noteView.setAlignment(.center, range: NSRange(location: 0, length: noteView.string.count))
            accessoryView.addSubview(noteView)
            
            alert.accessoryView = accessoryView
            
            alert.addButton(withTitle: "サブスクリプションをリストア")
            alert.buttons[0].tag = NSApplication.ModalResponse.OK.rawValue
            if ValidTransactions.instance.containsAnyProductId() {
                alert.addButton(withTitle: "キャンセル")
                alert.buttons[1].tag = NSApplication.ModalResponse.cancel.rawValue
            } else {
                alert.addButton(withTitle: "登録せずにアプリを終了")
                alert.buttons[1].tag = NSApplication.ModalResponse.alertSecondButtonReturn.rawValue
            }
            
            
            let result = alert.runModal()
            
            if result == .OK {
                
                do {
                    try await Products.instance.restore()
                    // ユーザー操作禁止を解除
                    AppDelegate.setViewIsHidden(false)
                } catch {
                    let alert = NSAlert()
                    alert.alertStyle = .warning
                    alert.messageText = "リストアエラー"
                    alert.informativeText = error.localizedDescription
                    alert.runModal()
                    
                    // TODO 再度サブスクリプション選択画面を表示 -> AppDelegate.applicationWillBecomeActiveが自動的に呼ばれる？
                    return
                }
            }
            else if result == .cancel { AppDelegate.setViewIsHidden(false) }
            else if result == .alertSecondButtonReturn { NSApplication.shared.terminate(self) }
        }
    }
    
    // サブスクリプション購入
    func subscribe(productId: ProductId) async throws -> StoreKit.Transaction  {
        guard let product = find(productId: productId) else { throw SubscriptionError.otherError }
        
        // 購入処理をしてProduct.PurchaseResultを取得
        let purchaseResult: Product.PurchaseResult
        do {
            purchaseResult = try await product.purchase()
        } catch Product.PurchaseError.productUnavailable {
            throw SubscriptionError.productUnavailable
        } catch Product.PurchaseError.purchaseNotAllowed {
            throw SubscriptionError.purchaseNotAllowed
        } catch {
            throw SubscriptionError.otherError
        }

        // VerificationResultの取得
        let verificationResult: VerificationResult<StoreKit.Transaction>
        switch purchaseResult {
        case .success(let result):
            verificationResult = result
        case .userCancelled:
            throw SubscriptionError.userCancelled
        case .pending:
            throw SubscriptionError.pending
        @unknown default:
            throw SubscriptionError.otherError
        }

        // Transactionの取得
        switch verificationResult {
        case .verified(let transaction):
            PurchaseChecker.checkPurchases(purchasedDates: [transaction.purchaseDate], productIDs: [transaction.productID])
            await transaction.finish()
            return transaction
        case .unverified:
            throw SubscriptionError.failedVerification
        }
    }
    
    func restore() async throws {
        do {
            try await AppStore.sync()
        } catch {
            throw SubscriptionError.failedRestore
        }
    }
}
