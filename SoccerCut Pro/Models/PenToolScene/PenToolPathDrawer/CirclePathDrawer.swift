//
//  CirclePathDrawer.swift
//  SoccerCut Pro
//
//  Created by Naoki Tanaka on 2023/08/06.
//

import Cocoa
import SwiftUI

struct CirclePathDrawer: PenToolPathDrawerProtocol {
    var style: PenToolPathStyle
    
    init() {
        // 初回起動時にはUserDefaultsKeyが保存されていないため、初期値を設定しておく。
        UserDefaults.standard.register(defaults: [PenToolStyleCircleUserDefaultsKey.colorData.rawValue : Color.black.jsonEncoded(),
                                                  PenToolStyleCircleUserDefaultsKey.opacity.rawValue : 100,
                                                  PenToolStyleCircleUserDefaultsKey.lineWidth.rawValue : 10,
                                                  PenToolStyleCircleUserDefaultsKey.circleDegrees.rawValue : 270])
        // UserDefaultsから読み込み
        let colorData = UserDefaults.standard.data(forKey: PenToolStyleCircleUserDefaultsKey.colorData.rawValue)
        let color = (colorData == nil) ? .black : Color.jsonDecoded(colorData!)
        let opacity = UserDefaults.standard.integer(forKey: PenToolStyleCircleUserDefaultsKey.opacity.rawValue)
        let lineWidth = UserDefaults.standard.integer(forKey: PenToolStyleCircleUserDefaultsKey.lineWidth.rawValue)
        let circleDegrees = UserDefaults.standard.integer(forKey: PenToolStyleCircleUserDefaultsKey.circleDegrees.rawValue)
        // 値を設定
        style = PenToolPathStyle(color: color, opacity: Int32(opacity), lineWidth: Int32(lineWidth), circleDegrees: Int32(circleDegrees))
    }
    
    func isValidInput(startInResolution: CGPoint, endInResolution: CGPoint) -> Bool {
        // 0に近い値になると除算時におかしくなるので回避
        let offset = startInResolution - endInResolution
        return abs(offset.x) > 3 && abs(offset.y) > 3
    }
    
    func makePath(startInResolution: CGPoint, endInResolution: CGPoint) -> any PenToolPathProtocol {
        var circlePath = CirclePath()
        circlePath.initialize(startInResolution: startInResolution, endInResolution: endInResolution)
        return circlePath
    }
    
    func saveStyle() {
        UserDefaults.standard.set(style.color.jsonEncoded(), forKey: PenToolStyleCircleUserDefaultsKey.colorData.rawValue)
        UserDefaults.standard.setValue(style.opacity, forKey: PenToolStyleCircleUserDefaultsKey.opacity.rawValue)
        UserDefaults.standard.setValue(style.lineWidth, forKey: PenToolStyleCircleUserDefaultsKey.lineWidth.rawValue)
        UserDefaults.standard.setValue(style.circleDegrees, forKey: PenToolStyleCircleUserDefaultsKey.circleDegrees.rawValue)
        UserDefaults.standard.synchronize()
    }
}
