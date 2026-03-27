//
//  LinePathDrawer.swift
//  SoccerCut Pro
//
//  Created by Naoki Tanaka on 2023/10/31.
//

import Cocoa
import SwiftUI

struct LinePathDrawer: PenToolPathDrawerProtocol {
    var style = PenToolPathStyle(color: .black, lineWidth: 10)
    
    init() {
        // 初回起動時にはUserDefaultsKeyが保存されていないため、初期値を設定しておく。
        UserDefaults.standard.register(defaults: [PenToolStyleLineUserDefaultsKey.colorData.rawValue : Color.black.jsonEncoded(),
                                                  PenToolStyleLineUserDefaultsKey.opacity.rawValue : 100,
                                                  PenToolStyleLineUserDefaultsKey.lineWidth.rawValue : 10])
        // UserDefaultsから読み込み
        let colorData = UserDefaults.standard.data(forKey: PenToolStyleLineUserDefaultsKey.colorData.rawValue)
        let color = (colorData == nil) ? .black : Color.jsonDecoded(colorData!)
        let opacity = UserDefaults.standard.integer(forKey: PenToolStyleLineUserDefaultsKey.opacity.rawValue)
        let lineWidth = UserDefaults.standard.integer(forKey: PenToolStyleLineUserDefaultsKey.lineWidth.rawValue)
        // 値を設定
        style = PenToolPathStyle(color: color, opacity: Int32(opacity), lineWidth: Int32(lineWidth))
    }
    
    func isValidInput(startInResolution: CGPoint, endInResolution: CGPoint) -> Bool {
        let vector = endInResolution - startInResolution
        return vector.length > 0
    }
    
    func makePath(startInResolution: CGPoint, endInResolution: CGPoint) -> any PenToolPathProtocol {
        var linePath = LinePath()
        linePath.initialize(startInResolution: startInResolution, endInResolution: endInResolution)
        return linePath
    }
    
    func saveStyle() {
        UserDefaults.standard.set(style.color.jsonEncoded(), forKey: PenToolStyleLineUserDefaultsKey.colorData.rawValue)
        UserDefaults.standard.setValue(style.opacity, forKey: PenToolStyleLineUserDefaultsKey.opacity.rawValue)
        UserDefaults.standard.setValue(style.lineWidth, forKey: PenToolStyleLineUserDefaultsKey.lineWidth.rawValue)
        UserDefaults.standard.synchronize()
    }
}
