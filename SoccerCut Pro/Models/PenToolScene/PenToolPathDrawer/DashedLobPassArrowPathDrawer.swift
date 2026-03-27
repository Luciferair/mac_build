//
//  DashedLobPassArrowPathDrawer.swift
//  SoccerCut Pro

import SwiftUI

struct DashedLobPassArrowPathDrawer: PenToolPathDrawerProtocol {
    var style: PenToolPathStyle

    init() {
        UserDefaults.standard.register(defaults: [
            PenToolStyleDashedLobPassArrowUserDefaultsKey.colorData.rawValue: Color.black.jsonEncoded()!,
            PenToolStyleDashedLobPassArrowUserDefaultsKey.opacity.rawValue: 100,
            PenToolStyleDashedLobPassArrowUserDefaultsKey.lineWidth.rawValue: 10,
            PenToolStyleDashedLobPassArrowUserDefaultsKey.arrowheadSize.rawValue: 27,
            PenToolStyleDashedLobPassArrowUserDefaultsKey.lineTopHeight.rawValue: 200,
            PenToolStyleDashedLobPassArrowUserDefaultsKey.dashLength.rawValue: 10,
            PenToolStyleDashedLobPassArrowUserDefaultsKey.dashInterval.rawValue: 10
        ])
        let colorData = UserDefaults.standard.data(forKey: PenToolStyleDashedLobPassArrowUserDefaultsKey.colorData.rawValue)
        let color: Color = colorData == nil ? .black : Color.jsonDecoded(colorData!)
        style = PenToolPathStyle(
            color: color,
            opacity: Int32(UserDefaults.standard.integer(forKey: PenToolStyleDashedLobPassArrowUserDefaultsKey.opacity.rawValue)),
            lineWidth: Int32(UserDefaults.standard.integer(forKey: PenToolStyleDashedLobPassArrowUserDefaultsKey.lineWidth.rawValue)),
            arrowheadSize: Int32(UserDefaults.standard.integer(forKey: PenToolStyleDashedLobPassArrowUserDefaultsKey.arrowheadSize.rawValue)),
            lineTopHeight: Int32(UserDefaults.standard.integer(forKey: PenToolStyleDashedLobPassArrowUserDefaultsKey.lineTopHeight.rawValue)),
            dashLength: Int32(UserDefaults.standard.integer(forKey: PenToolStyleDashedLobPassArrowUserDefaultsKey.dashLength.rawValue)),
            dashInterval: Int32(UserDefaults.standard.integer(forKey: PenToolStyleDashedLobPassArrowUserDefaultsKey.dashInterval.rawValue))
        )
    }

    func isValidInput(startInResolution: CGPoint, endInResolution: CGPoint) -> Bool {
        (endInResolution - startInResolution).length >= CGFloat(style.arrowheadSize)
    }

    func makePath(startInResolution: CGPoint, endInResolution: CGPoint) -> any PenToolPathProtocol {
        var p = DashedLobPassArrowPath()
        p.initialize(startInResolution: startInResolution, endInResolution: endInResolution)
        return p
    }

    func saveStyle() {
        UserDefaults.standard.set(style.color.jsonEncoded(), forKey: PenToolStyleDashedLobPassArrowUserDefaultsKey.colorData.rawValue)
        UserDefaults.standard.setValue(style.opacity,       forKey: PenToolStyleDashedLobPassArrowUserDefaultsKey.opacity.rawValue)
        UserDefaults.standard.setValue(style.lineWidth,     forKey: PenToolStyleDashedLobPassArrowUserDefaultsKey.lineWidth.rawValue)
        UserDefaults.standard.setValue(style.arrowheadSize, forKey: PenToolStyleDashedLobPassArrowUserDefaultsKey.arrowheadSize.rawValue)
        UserDefaults.standard.setValue(style.lineTopHeight, forKey: PenToolStyleDashedLobPassArrowUserDefaultsKey.lineTopHeight.rawValue)
        UserDefaults.standard.setValue(style.dashLength,    forKey: PenToolStyleDashedLobPassArrowUserDefaultsKey.dashLength.rawValue)
        UserDefaults.standard.setValue(style.dashInterval,  forKey: PenToolStyleDashedLobPassArrowUserDefaultsKey.dashInterval.rawValue)
        UserDefaults.standard.synchronize()
    }
}
