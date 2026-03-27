//
//  DashedArrowPathDrawer.swift
//  SoccerCut Pro
//
//  Created by Naoki Tanaka on 2023/10/31.
//

import Cocoa
import SwiftUI

struct DashedArrowPathDrawer: PenToolPathDrawerProtocol {
    var style: PenToolPathStyle
    
    init() {
        // 初回起動時にはUserDefaultsKeyが保存されていないため、初期値を設定しておく。
        UserDefaults.standard.register(defaults: [PenToolStyleDashedArrowUserDefaultsKey.colorData.rawValue : Color.black.jsonEncoded(),
                                                  PenToolStyleDashedArrowUserDefaultsKey.opacity.rawValue : 100,
                                                  PenToolStyleDashedArrowUserDefaultsKey.lineWidth.rawValue : 10,
                                                  PenToolStyleDashedArrowUserDefaultsKey.arrowheadSize.rawValue : 27,
                                                  PenToolStyleDashedArrowUserDefaultsKey.dashLength.rawValue: 10,
                                                  PenToolStyleDashedArrowUserDefaultsKey.dashInterval.rawValue: 10])
        // UserDefaultsから読み込み
        let colorData = UserDefaults.standard.data(forKey: PenToolStyleDashedArrowUserDefaultsKey.colorData.rawValue)
        let color = (colorData == nil) ? .black : Color.jsonDecoded(colorData!)
        let opacity = UserDefaults.standard.integer(forKey: PenToolStyleDashedArrowUserDefaultsKey.opacity.rawValue)
        let lineWidth = UserDefaults.standard.integer(forKey: PenToolStyleDashedArrowUserDefaultsKey.lineWidth.rawValue)
        let arrowheadSize = UserDefaults.standard.integer(forKey: PenToolStyleDashedArrowUserDefaultsKey.arrowheadSize.rawValue)
        let dashLength = UserDefaults.standard.integer(forKey: PenToolStyleDashedArrowUserDefaultsKey.dashLength.rawValue)
        let dashInterval = UserDefaults.standard.integer(forKey: PenToolStyleDashedArrowUserDefaultsKey.dashInterval.rawValue)
        // 値を設定
        style = PenToolPathStyle(color: color, opacity: Int32(opacity), lineWidth: Int32(lineWidth), arrowheadSize: Int32(arrowheadSize),
                                 dashLength: Int32(dashLength), dashInterval: Int32(dashInterval))
    }
    
    func isValidInput(startInResolution: CGPoint, endInResolution: CGPoint) -> Bool {
        let vector = endInResolution - startInResolution
        let arrowheadSize = style.arrowheadSize
        return vector.length >= CGFloat(arrowheadSize) // 画面左上から描画してしまったりする不具合を防止
    }
    
    func makePath(startInResolution: CGPoint, endInResolution: CGPoint) -> any PenToolPathProtocol {
        var dashedArrowPath = DashedArrowPath()
        dashedArrowPath.initialize(startInResolution: startInResolution, endInResolution: endInResolution)
        return dashedArrowPath
    }
    
    func saveStyle() {
        UserDefaults.standard.set(style.color.jsonEncoded(), forKey: PenToolStyleDashedArrowUserDefaultsKey.colorData.rawValue)
        UserDefaults.standard.setValue(style.opacity, forKey: PenToolStyleDashedArrowUserDefaultsKey.opacity.rawValue)
        UserDefaults.standard.setValue(style.lineWidth, forKey: PenToolStyleDashedArrowUserDefaultsKey.lineWidth.rawValue)
        UserDefaults.standard.setValue(style.arrowheadSize, forKey: PenToolStyleDashedArrowUserDefaultsKey.arrowheadSize.rawValue)
        UserDefaults.standard.setValue(style.dashLength, forKey: PenToolStyleDashedArrowUserDefaultsKey.dashLength.rawValue)
        UserDefaults.standard.setValue(style.dashInterval, forKey: PenToolStyleDashedArrowUserDefaultsKey.dashInterval.rawValue)
        UserDefaults.standard.synchronize()
    }
}
