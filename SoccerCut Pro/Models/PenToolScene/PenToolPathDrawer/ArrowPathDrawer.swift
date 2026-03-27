//
//  ArrowPathDrawer.swift
//  SoccerCut Pro
//
//  Created by Naoki Tanaka on 2023/08/05.
//

import Cocoa
import SwiftUI

struct ArrowPathDrawer: PenToolPathDrawerProtocol {
    var style: PenToolPathStyle
    
    init() {
        // 初回起動時にはUserDefaultsKeyが保存されていないため、初期値を設定しておく。
        UserDefaults.standard.register(defaults: [PenToolStyleArrowUserDefaultsKey.colorData.rawValue : Color.black.jsonEncoded(),
                                                  PenToolStyleArrowUserDefaultsKey.opacity.rawValue : 100,
                                                  PenToolStyleArrowUserDefaultsKey.lineWidth.rawValue : 10,
                                                  PenToolStyleArrowUserDefaultsKey.arrowheadSize.rawValue : 27])
        // UserDefaultsから読み込み
        let colorData = UserDefaults.standard.data(forKey: PenToolStyleArrowUserDefaultsKey.colorData.rawValue)
        let color = (colorData == nil) ? .black : Color.jsonDecoded(colorData!)
        let opacity = UserDefaults.standard.integer(forKey: PenToolStyleArrowUserDefaultsKey.opacity.rawValue)
        let lineWidth = UserDefaults.standard.integer(forKey: PenToolStyleArrowUserDefaultsKey.lineWidth.rawValue)
        let arrowheadSize = UserDefaults.standard.integer(forKey: PenToolStyleArrowUserDefaultsKey.arrowheadSize.rawValue)
        // 値を設定
        style = PenToolPathStyle(color: color, opacity: Int32(opacity), lineWidth: Int32(lineWidth), arrowheadSize: Int32(arrowheadSize))
    }
    
    func isValidInput(startInResolution: CGPoint, endInResolution: CGPoint) -> Bool {
        let vector = endInResolution - startInResolution
        let arrowheadSize = style.arrowheadSize
        return vector.length >= CGFloat(arrowheadSize) // 画面左上から描画してしまったりする不具合を防止
    }
    
    func makePath(startInResolution: CGPoint, endInResolution: CGPoint) -> any PenToolPathProtocol {
        var arrowPath = ArrowPath()
        arrowPath.initialize(startInResolution: startInResolution, endInResolution: endInResolution)
        return arrowPath
    }
    
    func saveStyle() {
        UserDefaults.standard.set(style.color.jsonEncoded(), forKey: PenToolStyleArrowUserDefaultsKey.colorData.rawValue)
        UserDefaults.standard.setValue(style.opacity, forKey: PenToolStyleArrowUserDefaultsKey.opacity.rawValue)
        UserDefaults.standard.setValue(style.lineWidth, forKey: PenToolStyleArrowUserDefaultsKey.lineWidth.rawValue)
        UserDefaults.standard.setValue(style.arrowheadSize, forKey: PenToolStyleArrowUserDefaultsKey.arrowheadSize.rawValue)
        UserDefaults.standard.synchronize()
    }
}
