//
//  PenToolStyleDashedArrowUserDefaultsKey.swift
//  SoccerCut Pro
//
//  Created by Naoki Tanaka on 2023/11/08.
//

public enum PenToolStyleDashedArrowUserDefaultsKey: String {
    case colorData = "penToolStyleDashedArrowColorData"
    case opacity = "penToolStyleDashedArrowOpacity"
    case lineWidth = "penToolStyleDashedArrowLineWidth"
    case arrowheadSize = "penToolStyleDashedArrowArrowheadSize" // DashedArrowのArrowheadSizeなので、Arrowが2回続くのが正しい
    case dashLength = "penToolStyleDashedArrowDashLength"
    case dashInterval = "penToolStyleDashedArrowDashInterval"
}
