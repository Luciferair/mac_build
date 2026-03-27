//
//  SubscriptionError.swift
//  SoccerCut Pro
//
//  Created by Naoki Tanaka on 2023/06/16.
//

import Foundation

enum SubscriptionError: LocalizedError {
    case failedFetchingProductId // 製品IDの取得に失敗
    case productIdNotFound // 取得した製品IDが空だった
    case selectedDoNotSubscribe // ユーザーがサブスクリプション登録しないを選択した
    case userCancelled // ユーザーによって購入がキャンセルされた
    case pending // クレジットカードが未設定などの理由で購入が保留された
    case productUnavailable // 指定した商品が無効
    case purchaseNotAllowed // OSの支払い機能が無効化されている
    case failedVerification // トランザクションデータの署名が不正
    case failedRestore // リストアに失敗
    case otherError // その他のエラー
    
    // errorDescriptionプロパティを実装すれば、Error.localizedDescriptionはこのプロパティを参照してくれる。
    var errorDescription: String? {
        switch self {
        case .failedFetchingProductId: return "製品ID取得に失敗しました。\nネットワーク環境が問題ないかご確認ください。"
        case .productIdNotFound: return "製品IDが見つかりませんでした。"
        case .selectedDoNotSubscribe: return "サブスクリプションに登録しませんでした。"
        case .userCancelled: return "ユーザーによって購入がキャンセルされました。"
        case .pending: return "購入が保留されています。"
        case .productUnavailable: return "指定した商品が無効です。"
        case .purchaseNotAllowed: return "OSの支払い機能が無効化されています。"
        case .failedVerification: return "トランザクションデータの署名が不正です。"
        case .failedRestore: return "サブスクリプションのリストアに失敗しました。"
        default: return "不明なエラーが発生しました。"
        }
    }
}
