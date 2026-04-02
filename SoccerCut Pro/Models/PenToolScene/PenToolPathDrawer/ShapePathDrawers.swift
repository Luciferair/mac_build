//
//  ShapePathDrawers.swift
//  SoccerCut Pro

import SwiftUI

struct TrianglePathDrawer: PenToolPathDrawerProtocol {
    var style: PenToolPathStyle
    init() {
        UserDefaults.standard.register(defaults: [
            PenToolStyleTriangleUserDefaultsKey.colorData.rawValue: Color.black.jsonEncoded()!,
            PenToolStyleTriangleUserDefaultsKey.opacity.rawValue: 100,
            PenToolStyleTriangleUserDefaultsKey.lineWidth.rawValue: 10
        ])
        let colorData = UserDefaults.standard.data(forKey: PenToolStyleTriangleUserDefaultsKey.colorData.rawValue)
        style = PenToolPathStyle(
            color: colorData == nil ? .black : Color.jsonDecoded(colorData!),
            opacity: Int32(UserDefaults.standard.integer(forKey: PenToolStyleTriangleUserDefaultsKey.opacity.rawValue)),
            lineWidth: Int32(UserDefaults.standard.integer(forKey: PenToolStyleTriangleUserDefaultsKey.lineWidth.rawValue))
        )
    }
    func isValidInput(startInResolution: CGPoint, endInResolution: CGPoint) -> Bool {
        let d = endInResolution - startInResolution; return abs(d.x) > 5 && abs(d.y) > 5
    }
    func makePath(startInResolution: CGPoint, endInResolution: CGPoint) -> any PenToolPathProtocol {
        var p = TrianglePath(); p.initialize(startInResolution: startInResolution, endInResolution: endInResolution); return p
    }
    func saveStyle() {
        UserDefaults.standard.set(style.color.jsonEncoded(), forKey: PenToolStyleTriangleUserDefaultsKey.colorData.rawValue)
        UserDefaults.standard.setValue(style.opacity,   forKey: PenToolStyleTriangleUserDefaultsKey.opacity.rawValue)
        UserDefaults.standard.setValue(style.lineWidth, forKey: PenToolStyleTriangleUserDefaultsKey.lineWidth.rawValue)
        UserDefaults.standard.synchronize()
    }
}

struct TriangleFillPathDrawer: PenToolPathDrawerProtocol {
    var style: PenToolPathStyle
    init() {
        UserDefaults.standard.register(defaults: [
            PenToolStyleTriangleFillUserDefaultsKey.colorData.rawValue: Color.black.jsonEncoded()!,
            PenToolStyleTriangleFillUserDefaultsKey.opacity.rawValue: 100
        ])
        let colorData = UserDefaults.standard.data(forKey: PenToolStyleTriangleFillUserDefaultsKey.colorData.rawValue)
        style = PenToolPathStyle(
            color: colorData == nil ? .black : Color.jsonDecoded(colorData!),
            opacity: Int32(UserDefaults.standard.integer(forKey: PenToolStyleTriangleFillUserDefaultsKey.opacity.rawValue)),
            lineWidth: 0
        )
    }
    func isValidInput(startInResolution: CGPoint, endInResolution: CGPoint) -> Bool {
        let d = endInResolution - startInResolution; return abs(d.x) > 5 && abs(d.y) > 5
    }
    func makePath(startInResolution: CGPoint, endInResolution: CGPoint) -> any PenToolPathProtocol {
        var p = TriangleFillPath(); p.initialize(startInResolution: startInResolution, endInResolution: endInResolution); return p
    }
    func saveStyle() {
        UserDefaults.standard.set(style.color.jsonEncoded(), forKey: PenToolStyleTriangleFillUserDefaultsKey.colorData.rawValue)
        UserDefaults.standard.setValue(style.opacity, forKey: PenToolStyleTriangleFillUserDefaultsKey.opacity.rawValue)
        UserDefaults.standard.synchronize()
    }
}

struct RectanglePathDrawer: PenToolPathDrawerProtocol {
    var style: PenToolPathStyle
    init() {
        UserDefaults.standard.register(defaults: [
            PenToolStyleRectangleUserDefaultsKey.colorData.rawValue: Color.black.jsonEncoded()!,
            PenToolStyleRectangleUserDefaultsKey.opacity.rawValue: 100,
            PenToolStyleRectangleUserDefaultsKey.lineWidth.rawValue: 10
        ])
        let colorData = UserDefaults.standard.data(forKey: PenToolStyleRectangleUserDefaultsKey.colorData.rawValue)
        style = PenToolPathStyle(
            color: colorData == nil ? .black : Color.jsonDecoded(colorData!),
            opacity: Int32(UserDefaults.standard.integer(forKey: PenToolStyleRectangleUserDefaultsKey.opacity.rawValue)),
            lineWidth: Int32(UserDefaults.standard.integer(forKey: PenToolStyleRectangleUserDefaultsKey.lineWidth.rawValue))
        )
    }
    func isValidInput(startInResolution: CGPoint, endInResolution: CGPoint) -> Bool {
        let d = endInResolution - startInResolution; return abs(d.x) > 5 && abs(d.y) > 5
    }
    func makePath(startInResolution: CGPoint, endInResolution: CGPoint) -> any PenToolPathProtocol {
        var p = RectanglePath(); p.initialize(startInResolution: startInResolution, endInResolution: endInResolution); return p
    }
    func saveStyle() {
        UserDefaults.standard.set(style.color.jsonEncoded(), forKey: PenToolStyleRectangleUserDefaultsKey.colorData.rawValue)
        UserDefaults.standard.setValue(style.opacity,   forKey: PenToolStyleRectangleUserDefaultsKey.opacity.rawValue)
        UserDefaults.standard.setValue(style.lineWidth, forKey: PenToolStyleRectangleUserDefaultsKey.lineWidth.rawValue)
        UserDefaults.standard.synchronize()
    }
}

struct RectangleFillPathDrawer: PenToolPathDrawerProtocol {
    var style: PenToolPathStyle
    init() {
        UserDefaults.standard.register(defaults: [
            PenToolStyleRectangleFillUserDefaultsKey.colorData.rawValue: Color.black.jsonEncoded()!,
            PenToolStyleRectangleFillUserDefaultsKey.opacity.rawValue: 100
        ])
        let colorData = UserDefaults.standard.data(forKey: PenToolStyleRectangleFillUserDefaultsKey.colorData.rawValue)
        style = PenToolPathStyle(
            color: colorData == nil ? .black : Color.jsonDecoded(colorData!),
            opacity: Int32(UserDefaults.standard.integer(forKey: PenToolStyleRectangleFillUserDefaultsKey.opacity.rawValue)),
            lineWidth: 0
        )
    }
    func isValidInput(startInResolution: CGPoint, endInResolution: CGPoint) -> Bool {
        let d = endInResolution - startInResolution; return abs(d.x) > 5 && abs(d.y) > 5
    }
    func makePath(startInResolution: CGPoint, endInResolution: CGPoint) -> any PenToolPathProtocol {
        var p = RectangleFillPath(); p.initialize(startInResolution: startInResolution, endInResolution: endInResolution); return p
    }
    func saveStyle() {
        UserDefaults.standard.set(style.color.jsonEncoded(), forKey: PenToolStyleRectangleFillUserDefaultsKey.colorData.rawValue)
        UserDefaults.standard.setValue(style.opacity, forKey: PenToolStyleRectangleFillUserDefaultsKey.opacity.rawValue)
        UserDefaults.standard.synchronize()
    }
}

struct ConnectedCirclesPathDrawer: PenToolPathDrawerProtocol {
    var style: PenToolPathStyle
    init() {
        UserDefaults.standard.register(defaults: [
            PenToolStyleConnectedCirclesUserDefaultsKey.colorData.rawValue: Color.black.jsonEncoded()!,
            PenToolStyleConnectedCirclesUserDefaultsKey.opacity.rawValue: 100,
            PenToolStyleConnectedCirclesUserDefaultsKey.lineWidth.rawValue: 10,
            PenToolStyleConnectedCirclesUserDefaultsKey.circleDegrees.rawValue: 270
        ])
        let colorData = UserDefaults.standard.data(forKey: PenToolStyleConnectedCirclesUserDefaultsKey.colorData.rawValue)
        style = PenToolPathStyle(
            color: colorData == nil ? .black : Color.jsonDecoded(colorData!),
            opacity: Int32(UserDefaults.standard.integer(forKey: PenToolStyleConnectedCirclesUserDefaultsKey.opacity.rawValue)),
            lineWidth: Int32(UserDefaults.standard.integer(forKey: PenToolStyleConnectedCirclesUserDefaultsKey.lineWidth.rawValue)),
            circleDegrees: Int32(UserDefaults.standard.integer(forKey: PenToolStyleConnectedCirclesUserDefaultsKey.circleDegrees.rawValue))
        )
    }
    func isValidInput(startInResolution: CGPoint, endInResolution: CGPoint) -> Bool {
        // Allow tap-to-place nodes for faster chained drawing.
        true
    }
    func makePath(startInResolution: CGPoint, endInResolution: CGPoint) -> any PenToolPathProtocol {
        var p = ConnectedCirclesPath(); p.initialize(startInResolution: startInResolution, endInResolution: endInResolution); return p
    }
    func saveStyle() {
        UserDefaults.standard.set(style.color.jsonEncoded(), forKey: PenToolStyleConnectedCirclesUserDefaultsKey.colorData.rawValue)
        UserDefaults.standard.setValue(style.opacity,   forKey: PenToolStyleConnectedCirclesUserDefaultsKey.opacity.rawValue)
        UserDefaults.standard.setValue(style.lineWidth, forKey: PenToolStyleConnectedCirclesUserDefaultsKey.lineWidth.rawValue)
        UserDefaults.standard.setValue(style.circleDegrees, forKey: PenToolStyleConnectedCirclesUserDefaultsKey.circleDegrees.rawValue)
        UserDefaults.standard.synchronize()
    }
}
