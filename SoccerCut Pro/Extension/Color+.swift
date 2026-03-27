//
//  Color+.swift
//  SoccerCut Pro
//
//  Created by Naoki Tanaka on 2023/08/11.
//

import SwiftUI

extension Color {
    var r: Double { return NSColor(self).rgba.red }
    var g: Double { return NSColor(self).rgba.green }
    var b: Double { return NSColor(self).rgba.blue }
    var a: Double { return NSColor(self).rgba.alpha }
}

extension Color: Codable {
    enum CodingKeys: String, CodingKey {
        case red
        case green
        case blue
        case opacity
    }
        
    public func encode(to encoder: Encoder) throws {
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var opacity: CGFloat = 0
        
        var container = encoder.container(keyedBy: CodingKeys.self)
        NSColor(self).getRed(&red, green: &green, blue: &blue, alpha: &opacity)
        try container.encode(red, forKey: .red)
        try container.encode(green, forKey: .green)
        try container.encode(blue, forKey: .blue)
        try container.encode(opacity, forKey: .opacity)
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let red = try container.decode(Double.self, forKey: .red)
        let green = try container.decode(Double.self, forKey: .green)
        let blue = try container.decode(Double.self, forKey: .blue)
        let opacity = try container.decode(Double.self, forKey: .opacity)
        self.init(red: red, green: green, blue: blue, opacity: opacity)
    }
    
    func jsonEncoded() -> Data? {
        let jsonEncoder = JSONEncoder()
        return try? jsonEncoder.encode(self)
    }
    
    static func jsonDecoded(_ json: Data) -> Color {
        let jsonDecoder = JSONDecoder()
        let color = try? jsonDecoder.decode(Color.self, from: json)
        return color ?? .black
    }
}
