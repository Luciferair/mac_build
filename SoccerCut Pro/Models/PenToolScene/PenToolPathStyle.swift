//
//  PenToolPathStyle.swift
//  SoccerCut Pro
//
//  Created by Naoki Tanaka on 2023/08/05.
//

import Cocoa
import SwiftUI

class PenToolPathStyle: ObservableObject {
    @Published var color: Color
    @Published var opacity: Int32
    @Published var lineWidth: Int32
    @Published var arrowheadSize: Int32
    @Published var lineTopHeight: Int32
    @Published var dashLength: Int32
    @Published var dashInterval: Int32
    @Published var circleDegrees: Int32
    @Published var fontSize: Int32
    @Published var textString: String
    @Published var isEraser: Bool
    
    // 本来はフラグ変数を定義したくないが、PenToolStylePanelでのViewの表示/非表示切替でわかりづらくなるので導入
    @Published var useColor: Bool
    @Published var useLineWidth: Bool
    @Published var useArrowheadSize: Bool
    @Published var useLineTopHeight: Bool
    @Published var useDashedLine: Bool
    @Published var useCircleDegrees: Bool
    @Published var useText: Bool
    
    // 値が0 = そのPathでは使わないStyle
    init(color: Color = .clear, opacity: Int32 = 100, lineWidth: Int32 = 0, arrowheadSize: Int32 = 0, lineTopHeight: Int32 = 0, dashLength: Int32 = 0, dashInterval: Int32 = 0, circleDegrees: Int32 = 0, fontSize: Int32 = 0, textString: String = "", isEraser: Bool = false) {
        self.color = color
        self.opacity = opacity
        self.lineWidth = lineWidth
        self.arrowheadSize = arrowheadSize
        self.lineTopHeight = lineTopHeight
        self.dashLength = dashLength
        self.dashInterval = dashInterval
        self.circleDegrees = circleDegrees
        self.fontSize = fontSize
        self.textString = textString
        self.isEraser = isEraser
        
        self.useColor = color != .clear
        self.useLineWidth = lineWidth != 0
        self.useArrowheadSize = arrowheadSize != 0
        self.useLineTopHeight = lineTopHeight != 0
        self.useDashedLine = dashLength != 0
        self.useCircleDegrees = circleDegrees != 0
        self.useText = fontSize != 0
    }
    
    func copyValues(from: PenToolPathStyle) {
        self.color = from.color
        self.opacity = from.opacity
        self.lineWidth = from.lineWidth
        self.arrowheadSize = from.arrowheadSize
        self.lineTopHeight = from.lineTopHeight
        self.dashLength = from.dashLength
        self.dashInterval = from.dashInterval
        self.circleDegrees = from.circleDegrees
        self.fontSize = from.fontSize
        self.textString = from.textString
        self.isEraser = from.isEraser
        
        self.useColor = color != .clear
        self.useLineWidth = lineWidth != 0
        self.useArrowheadSize = arrowheadSize != 0
        self.useLineTopHeight = lineTopHeight != 0
        self.useDashedLine = dashLength != 0
        self.useCircleDegrees = circleDegrees != 0
        self.useText = fontSize != 0
    }
}
