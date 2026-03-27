//
//  ProductSelectionButton.swift
//  SoccerCut Pro
//
//  Created by Naoki Tanaka on 2023/10/29.
//

import SwiftUI

struct ProductSelectionButton: View {
    private let productId: ProductId
    private let canClick: Bool
    private let label: String
    private var linearGradient: LinearGradient? = nil
    private var color: Color? = nil
    @State private var isHover = false
    
    init(productId: ProductId) {
        self.productId = productId
        
        switch productId {
        case .basicMonthly, .basicYearly:
            if ValidTransactions.instance.containsOneOfProductIds([productId]) {
                canClick = false
                label = "購入済み"
                color = .gray
            } else if productId == .basicMonthly && ValidTransactions.instance.containsOneOfProductIds([.basicYearly]) {
                canClick = false
                label = "年額購入済み"
                color = .gray
            } else if ValidTransactions.instance.containsOneOfProductIds([.expertMonthly, .expertYearly]) {
                canClick = false
                label = "Expert購入済み"
                color = .gray
            } else {
                canClick = true
                label = Products.instance.pricePerPeriodOf(productId: productId)
                color = .accentColor
            }
            break
            
        case .expertMonthly, .expertYearly:
            if ValidTransactions.instance.containsOneOfProductIds([productId]) {
                canClick = false
                label = "購入済み"
                color = .gray
            } else if productId == .expertMonthly && ValidTransactions.instance.containsOneOfProductIds([.expertYearly]) {
                canClick = false
                label = "年額購入済み"
                color = .gray
            } else {
                canClick = true
                if Products.instance.isEligibleForFreeTrial && productId.isFreeTrialAvailable { label = "初回2週間無料！" }
                else { label = Products.instance.pricePerPeriodOf(productId: productId) }
                linearGradient = LinearGradient(gradient: Gradient(colors: [.accentColor, .pink]), startPoint: .topLeading, endPoint: .bottomTrailing)
            }
            break
        }
    }
    
    var body: some View {
        Button(action: {
            // 一旦サブスクリプション選択アラートを解除しないと、他のアラートが出ない
            NSApplication.shared.abortModal()
            
            Task { @MainActor in
                do {
                    _ = try await Products.instance.subscribe(productId: productId)
                } catch {
                    let alert = NSAlert()
                    alert.alertStyle = .warning
                    alert.messageText = PurchaseType.purchase.rawValue + "エラー"
                    alert.informativeText = error.localizedDescription
                    alert.runModal()

                    // TODO 再度サブスクリプション選択画面を表示 -> AppDelegate.applicationWillBecomeActiveが自動的に呼ばれる？
                    AppDelegate.setViewIsHidden(false)
                    return
                }
                                                
                // ユーザー操作禁止を解除
                AppDelegate.setViewIsHidden(false)
            }
        }) {
            Text(label)
        }
        .buttonStyle(CustomButtonStyle(linearGradient: linearGradient, color: color))
        .onHover { hovering in
            isHover = hovering
        }
        .opacity(canClick && isHover ? 1.0 : 0.85)
        .disabled(!canClick)
    }
}

struct CustomButtonStyle : ButtonStyle {
    let linearGradient: LinearGradient?
    let color: Color?
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 14))
            .frame(width: 80, height: 40)
            .foregroundColor(.white)
            .if(linearGradient != nil) {
                $0.background(linearGradient)
            }
            .if(color != nil) {
                $0.background(color)
            }
            .cornerRadius(8)
            .padding(.horizontal, 10)
    }
}

struct ProductSelectionButton_Previews: PreviewProvider {
    static var previews: some View {
        EmptyView()
    }
}
