//
//  CircleFillPathDrawer.swift
//  SoccerCut Pro
//
//  Created by Naoki Tanaka on 2023/10/31.
//

import Cocoa
import SwiftUI

struct CircleFillPathDrawer: PenToolPathDrawerProtocol {
    var style: PenToolPathStyle
    
    init() {
        // 初回起動時にはUserDefaultsKeyが保存されていないため、初期値を設定しておく。
        UserDefaults.standard.register(defaults: [PenToolStyleCircleFillUserDefaultsKey.colorData.rawValue : Color.black.jsonEncoded(),
                                                  PenToolStyleCircleFillUserDefaultsKey.opacity.rawValue : 100])
        
        // UserDefaultsから読み込み
        let colorData = UserDefaults.standard.data(forKey: PenToolStyleCircleFillUserDefaultsKey.colorData.rawValue)
        let color = (colorData == nil) ? .black : Color.jsonDecoded(colorData!)
        let opacity = UserDefaults.standard.integer(forKey: PenToolStyleCircleFillUserDefaultsKey.opacity.rawValue)
        // 値を設定
        style = PenToolPathStyle(color: color, opacity: Int32(opacity))
    }
    
    func isValidInput(startInResolution: CGPoint, endInResolution: CGPoint) -> Bool {
        // 0に近い値になると除算時におかしくなるので回避
        let offset = startInResolution - endInResolution
        return abs(offset.x) > 3 && abs(offset.y) > 3
    }
    
    func makePath(startInResolution: CGPoint, endInResolution: CGPoint) -> any PenToolPathProtocol {
        var circleFillPath = CircleFillPath()
        circleFillPath.initialize(startInResolution: startInResolution, endInResolution: endInResolution)
        return circleFillPath
    }
    
    func saveStyle() {
        UserDefaults.standard.set(style.color.jsonEncoded(), forKey: PenToolStyleCircleFillUserDefaultsKey.colorData.rawValue)
        UserDefaults.standard.setValue(style.opacity, forKey: PenToolStyleCircleFillUserDefaultsKey.opacity.rawValue)
        UserDefaults.standard.synchronize()
    }
}
