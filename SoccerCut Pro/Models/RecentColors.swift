//
//  RecentColors.swift
//  SoccerCut Pro

import SwiftUI

class RecentColors: ObservableObject {
    static let shared = RecentColors()
    private let key = "recentColors"
    private let maxCount = 10

    @Published private(set) var colors: [Color] = []

    private init() { load() }

    private func load() {
        guard let dataList = UserDefaults.standard.array(forKey: key) as? [Data] else { return }
        colors = dataList.map { Color.jsonDecoded($0) }
    }

    func add(_ color: Color) {
        // remove duplicate
        colors.removeAll { NSColor($0).rgbaTuple == NSColor(color).rgbaTuple }
        colors.insert(color, at: 0)
        if colors.count > maxCount { colors = Array(colors.prefix(maxCount)) }
        let encoded = colors.compactMap { $0.jsonEncoded() }
        UserDefaults.standard.set(encoded, forKey: key)
        UserDefaults.standard.synchronize()
    }
}

private extension NSColor {
    var rgbaTuple: (CGFloat, CGFloat, CGFloat, CGFloat) {
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        let converted = usingColorSpace(.sRGB) ?? self
        converted.getRed(&r, green: &g, blue: &b, alpha: &a)
        return (r, g, b, a)
    }
}

private func == (lhs: (CGFloat,CGFloat,CGFloat,CGFloat), rhs: (CGFloat,CGFloat,CGFloat,CGFloat)) -> Bool {
    abs(lhs.0-rhs.0) < 0.01 && abs(lhs.1-rhs.1) < 0.01 && abs(lhs.2-rhs.2) < 0.01
}
