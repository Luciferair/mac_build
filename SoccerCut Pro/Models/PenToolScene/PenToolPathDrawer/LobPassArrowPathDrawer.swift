//
//  LobPassArrowPathDrawer.swift
//  SoccerCut Pro
//
//  Created by Naoki Tanaka on 2023/10/31.
//

import Cocoa
import SwiftUI

struct LobPassArrowPathDrawer: PenToolPathDrawerProtocol {
    var style: PenToolPathStyle
    
    init() {
        // 初回起動時にはUserDefaultsKeyが保存されていないため、初期値を設定しておく。
        UserDefaults.standard.register(defaults: [PenToolStyleLobPassArrowUserDefaultsKey.colorData.rawValue : Color.black.jsonEncoded(),
                                                  PenToolStyleLobPassArrowUserDefaultsKey.opacity.rawValue : 100,
                                                  PenToolStyleLobPassArrowUserDefaultsKey.lineWidth.rawValue : 10,
                                                  PenToolStyleLobPassArrowUserDefaultsKey.arrowheadSize.rawValue : 27,
                                                  PenToolStyleLobPassArrowUserDefaultsKey.lineTopHeight.rawValue : 200])
        // UserDefaultsから読み込み
        let colorData = UserDefaults.standard.data(forKey: PenToolStyleLobPassArrowUserDefaultsKey.colorData.rawValue)
        let color = (colorData == nil) ? .black : Color.jsonDecoded(colorData!)
        let opacity = UserDefaults.standard.integer(forKey: PenToolStyleLobPassArrowUserDefaultsKey.opacity.rawValue)
        let lineWidth = UserDefaults.standard.integer(forKey: PenToolStyleLobPassArrowUserDefaultsKey.lineWidth.rawValue)
        let arrowheadSize = UserDefaults.standard.integer(forKey: PenToolStyleLobPassArrowUserDefaultsKey.arrowheadSize.rawValue)
        let lineTopHeight = UserDefaults.standard.integer(forKey: PenToolStyleLobPassArrowUserDefaultsKey.lineTopHeight.rawValue)
        // 値を設定
        style = PenToolPathStyle(color: color, opacity: Int32(opacity), lineWidth: Int32(lineWidth), arrowheadSize: Int32(arrowheadSize), lineTopHeight: Int32(lineTopHeight))
    }
    
    func isValidInput(startInResolution: CGPoint, endInResolution: CGPoint) -> Bool {
        let vector = endInResolution - startInResolution
        let arrowheadSize = style.arrowheadSize
        return vector.length >= CGFloat(arrowheadSize) // 画面左上から描画してしまったりする不具合を防止
    }
    
    func makePath(startInResolution: CGPoint, endInResolution: CGPoint) -> any PenToolPathProtocol {
        var lobPassArrowPath = LobPassArrowPath()
        lobPassArrowPath.initialize(startInResolution: startInResolution, endInResolution: endInResolution)
        return lobPassArrowPath
    }
    
    func saveStyle() {
        UserDefaults.standard.set(style.color.jsonEncoded(), forKey: PenToolStyleLobPassArrowUserDefaultsKey.colorData.rawValue)
        UserDefaults.standard.setValue(style.opacity, forKey: PenToolStyleLobPassArrowUserDefaultsKey.opacity.rawValue)
        UserDefaults.standard.setValue(style.lineWidth, forKey: PenToolStyleLobPassArrowUserDefaultsKey.lineWidth.rawValue)
        UserDefaults.standard.setValue(style.arrowheadSize, forKey: PenToolStyleLobPassArrowUserDefaultsKey.arrowheadSize.rawValue)
        UserDefaults.standard.setValue(style.lineTopHeight, forKey: PenToolStyleLobPassArrowUserDefaultsKey.lineTopHeight.rawValue)
        UserDefaults.standard.synchronize()
    }
}
