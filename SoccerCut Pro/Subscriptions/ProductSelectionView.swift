//
//  ProductSelectionView.swift
//  SoccerCut Pro
//
//  Created by Naoki Tanaka on 2023/10/29.
//

import StoreKit
import SwiftUI

struct ProductSelectionView: View {
    private let columnWidths: [CGFloat] = [120, 100, 100, 100]
    private let rowHeights: [CGFloat] = [50, 50, 50, 50, 50]
    private let productList: [Product]
    
    init (productList: [Product]) {
        self.productList = productList
    }
            
    var body: some View {
        VStack {
            HStack {
                Text("サブスクリプション")
                    .controlSize(.large)
                    .frame(width: columnWidths[0], height: rowHeights[0])
                
                Text("Basic")
                    .controlSize(.large)
                    .frame(width: columnWidths[1], height: rowHeights[0])
                Text("Expert")
                    .controlSize(.large)
                    .frame(width: columnWidths[2], height: rowHeights[0])
            }
            
            HStack {
                Text("月額プラン")
                    .controlSize(.large)
                    .frame(width: columnWidths[0], height: rowHeights[1])
                
                ProductSelectionButton(productId: .basicMonthly)
                    .frame(width: columnWidths[1], height: rowHeights[1])
                ProductSelectionButton(productId: .expertMonthly)
                    .frame(width: columnWidths[2], height: rowHeights[1])
            }
            
            HStack {
                Text("年額プラン")
                    .controlSize(.large)
                    .frame(width: columnWidths[0], height: rowHeights[2])
                
                ProductSelectionButton(productId: .basicYearly)
                    .frame(width: columnWidths[1], height: rowHeights[2])
                ProductSelectionButton(productId: .expertYearly)
                    .frame(width: columnWidths[2], height: rowHeights[2])
            }
                
            HStack {
                HStack {
                    Image(systemName: "play.rectangle")
                        .controlSize(.large)
                    Text("プレーヤー")
                        .controlSize(.large)
                }
                .frame(width: columnWidths[0], height: rowHeights[3])
                
                Image(systemName: "checkmark")
                    .controlSize(.large)
                    .frame(width: columnWidths[1], height: rowHeights[3])
                Image(systemName: "checkmark")
                    .controlSize(.large)
                    .frame(width: columnWidths[2], height: rowHeights[3])
            }
            
            HStack {
                HStack {
                    Image(systemName: "pencil.and.outline")
                        .controlSize(.large)
                    Text("ペンツール")
                        .controlSize(.large)
                }
                .frame(width: columnWidths[0], height: rowHeights[4])
                
                Image(systemName: "")
                    .controlSize(.large)
                    .frame(width: columnWidths[1], height: rowHeights[4])
                Image(systemName: "checkmark")
                    .controlSize(.large)
                    .frame(width: columnWidths[2], height: rowHeights[4])
            }
        }
    }
}

struct ProductSelectionView_Previews: PreviewProvider {
    static var previews: some View {
        EmptyView()
    }
}
