//
//  TextPathDrawer.swift
//  SoccerCut Pro
//
//  Created by Naoki Tanaka on 2023/10/31.
//

import Cocoa
import SwiftUI

struct TextPathDrawer: PenToolPathDrawerProtocol {
    var style: PenToolPathStyle
    
    init() {
        // 初回起動時にはUserDefaultsKeyが保存されていないため、初期値を設定しておく。
        UserDefaults.standard.register(defaults: [PenToolStyleTextUserDefaultsKey.colorData.rawValue : Color.black.jsonEncoded(),
                                                  PenToolStyleTextUserDefaultsKey.opacity.rawValue : 100,
                                                  PenToolStyleTextUserDefaultsKey.fontSize.rawValue : 46])
        // UserDefaultsから読み込み
        let colorData = UserDefaults.standard.data(forKey: PenToolStyleTextUserDefaultsKey.colorData.rawValue)
        let color = (colorData == nil) ? .black : Color.jsonDecoded(colorData!)
        let opacity = UserDefaults.standard.integer(forKey: PenToolStyleTextUserDefaultsKey.opacity.rawValue)
        let fontSize = UserDefaults.standard.integer(forKey: PenToolStyleTextUserDefaultsKey.fontSize.rawValue)
        // 値を設定
        style = PenToolPathStyle(color: color, opacity: Int32(opacity), fontSize: Int32(fontSize), textString: "")
    }
    
    func isValidInput(startInResolution: CGPoint, endInResolution: CGPoint) -> Bool {
        return style.textString != ""
    }
    
    func makePath(startInResolution: CGPoint, endInResolution: CGPoint) -> any PenToolPathProtocol {
        var textPath = TextPath()
        textPath.initialize(startInResolution: startInResolution, endInResolution: endInResolution)
        return textPath
    }
    
    func saveStyle() {
        UserDefaults.standard.set(style.color.jsonEncoded(), forKey: PenToolStyleTextUserDefaultsKey.colorData.rawValue)
        UserDefaults.standard.setValue(style.opacity, forKey: PenToolStyleTextUserDefaultsKey.opacity.rawValue)
        UserDefaults.standard.setValue(style.fontSize, forKey: PenToolStyleTextUserDefaultsKey.fontSize.rawValue)
        UserDefaults.standard.synchronize()
    }
}
