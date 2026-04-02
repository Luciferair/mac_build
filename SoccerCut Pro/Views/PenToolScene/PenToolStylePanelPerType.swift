//
//  PenToolStylePanel.swift
//  SoccerCut Pro
//
//  Created by Naoki Tanaka on 2023/08/11.
//

import SwiftUI

struct PenToolStylePanelPerType: View {
    @State private var type: PenToolType
    @ObservedObject private(set) var pathFactory: PenToolPathFactory
    @ObservedObject private(set) var style: PenToolPathStyle
    @ObservedObject private var recentColors = RecentColors.shared
    @FocusState private var isFocusedOnTextEditor: Bool
    
    private let spacing: CGFloat = 15
    private let commonNumberFormatter = NumberFormatter()
    private let commonMin: UInt16 = 1
    private let commonMax: UInt16 = 40
    private let circleNumberFormatter = NumberFormatter()
    
    init(type: PenToolType) {
        self.type = type
        pathFactory = PenToolModel.now.pathFactory
        style = PenToolModel.now.pathFactory.styleOf(type)
                
        commonNumberFormatter.minimum = NSNumber(value: commonMin)
        commonNumberFormatter.maximum = NSNumber(value: commonMax)
        circleNumberFormatter.minimum = NSNumber(value: 1)
        circleNumberFormatter.maximum = NSNumber(value: 360)
    }

    private var selectedConnectedNodeAngleBinding: Binding<Int32> {
        Binding(
            get: { pathFactory.pathHistory.selectedConnectedCirclesNodeAngle() ?? 270 },
            set: { pathFactory.pathHistory.setAngleToSelectedConnectedCirclesNode($0) }
        )
    }
        
    var body: some View {
        if pathFactory.currentType == type {
            VStack { // VStackのSpacingで間隔を設定すると、Sectionとその中身の間まで空いてしまうので、個別に設定suru
                if $style.useColor.wrappedValue {
                    Section(header: Text("色")) {
                        ColorPicker("", selection: $style.color, supportsOpacity: false)
                            .padding(.bottom, 4)
                            .onChange(of: style.color) { value in
                                RecentColors.shared.add(value)
                                pathFactory.pathHistory.applyStyleToSelectedPath(style)
                            }
                        // 最近使った色
                        if !recentColors.colors.isEmpty {
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 4) {
                                    ForEach(recentColors.colors.indices, id: \.self) { i in
                                        let c = recentColors.colors[i]
                                        Circle()
                                            .fill(c)
                                            .frame(width: 18, height: 18)
                                            .overlay(Circle().stroke(Color.white.opacity(0.4), lineWidth: 1))
                                            .onTapGesture {
                                                style.color = c
                                                pathFactory.pathHistory.applyStyleToSelectedPath(style)
                                            }
                                    }
                                }
                                .padding(.horizontal, 4)
                            }
                            .padding(.bottom, spacing)
                        }
                    }  // end Section 色
                    
                    Section(header: Text("不透明度")) {
                        HStack {
                            PenToolStyleSlider(value: $style.opacity, minValue: 0, maxValue: 100, step: 1, showValueLabel: false)
                                .onChange(of: style.opacity, perform: { value in
                                    pathFactory.pathHistory.applyStyleToSelectedPath(style)
                                })
                            Text(String(style.opacity))
                                .frame(width: 25, height: 10)
                                .padding(.leading, -5)
                        }
                        .padding(.horizontal, 10)
                        .padding(.bottom, spacing)
                    }
                }
                
                if $style.useLineWidth.wrappedValue {
                    Section(header: Text("線の太さ")) {
                        PenToolStyleSlider(value: $style.lineWidth, minValue: 1, maxValue: 40, step: 1)
                            .padding(.horizontal, 10)
                            .padding(.bottom, spacing)
                            .onChange(of: style.lineWidth, perform: { value in
                                pathFactory.pathHistory.applyStyleToSelectedPath(style)
                            })
                    }
                }
                
                if $style.useArrowheadSize.wrappedValue {
                    Section(header: Text("矢尻のサイズ")) {
                        HStack {
                            PenToolStyleSlider(value: $style.arrowheadSize, minValue: 15, maxValue: 42, step: 3, showValueLabel: false)
                                .onChange(of: style.arrowheadSize, perform: { value in
                                    pathFactory.pathHistory.applyStyleToSelectedPath(style)
                                })
                            Text(String((style.arrowheadSize - 15) / 3 + 1)) // ラベルの値は1~10に変換
                                .frame(width: 20, height: 10)
                                .padding(.leading, -5)
                        }
                        .padding(.horizontal, 10)
                        .padding(.bottom, spacing)
                    }
                }
                
                if $style.useLineTopHeight.wrappedValue {
                    Section(header: Text("線の頂点の高さ")) {
                        HStack {
                            PenToolStyleSlider(value: $style.lineTopHeight, minValue: 40, maxValue: 400, step: 40, showValueLabel: false)
                                .onChange(of: style.lineTopHeight, perform: { value in
                                    pathFactory.pathHistory.applyStyleToSelectedPath(style)
                                })
                            Text(String(style.lineTopHeight / 40)) // ラベルの値は1~10に変換
                                .frame(width: 20, height: 10)
                                .padding(.leading, -5)
                        }
                        .padding(.horizontal, 10)
                        .padding(.bottom, spacing)
                    }
                }
                
                if $style.useDashedLine.wrappedValue {
                    Section(header: Text("点線の長さ")) {
                        PenToolStyleSlider(value: $style.dashLength, minValue: 1, maxValue: 40, step: 1)
                            .padding(.horizontal, 10)
                            .padding(.bottom, spacing)
                            .onChange(of: style.dashLength, perform: { value in
                                pathFactory.pathHistory.applyStyleToSelectedPath(style)
                            })
                    }

                    Section(header: Text("点線の間隔")) {
                        PenToolStyleSlider(value: $style.dashInterval, minValue: 1, maxValue: 40, step: 1)
                            .padding(.horizontal, 10)
                            .padding(.bottom, spacing)
                            .onChange(of: style.dashInterval, perform: { value in
                                pathFactory.pathHistory.applyStyleToSelectedPath(style)
                            })
                    }
                }
                
                if $style.useCircleDegrees.wrappedValue {
                    Section(header: Text("円を描く角度")) {
                        HStack {
                            PenToolStyleSlider(value: $style.circleDegrees, minValue: 210, maxValue: 360, step: 1, showValueLabel: false)
                                .onChange(of: style.circleDegrees, perform: { value in
                                    pathFactory.pathHistory.applyStyleToSelectedPath(style)
                                })
                            Text(String(style.circleDegrees))
                                .frame(width: 25, height: 10)
                                .padding(.leading, -5)
                        }
                        .padding(.horizontal, 10)
                        .padding(.bottom, spacing)
                    }

                    if type == .connectedCircles {
                        Section(header: Text("選択中プレイヤーの向き")) {
                            HStack {
                                PenToolStyleSlider(value: selectedConnectedNodeAngleBinding, minValue: 0, maxValue: 359, step: 1, showValueLabel: false)
                                Text(String(pathFactory.pathHistory.selectedConnectedCirclesNodeAngle() ?? 270))
                                    .frame(width: 30, height: 10)
                                    .padding(.leading, -5)
                            }
                            .padding(.horizontal, 10)
                            Text("円をクリックすると個別向きを変更できます")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            .padding(.bottom, spacing)
                        }
                    }
                }
                
                if $style.useText.wrappedValue {
                    Section(header: Text("フォントサイズ")) {
                        HStack {
                            PenToolStyleSlider(value: $style.fontSize, minValue: 10, maxValue: 86, step: 4, showValueLabel: false)
                                .onChange(of: style.fontSize, perform: { value in
                                    pathFactory.pathHistory.applyStyleToSelectedPath(style)
                                })
                            Text(String((style.fontSize - 10) / 4 + 1))
                                .frame(width: 20, height: 10)
                                .padding(.leading, -5)
                        }
                        .padding(.horizontal, 10)
                        .padding(.bottom, spacing)
                    }
                    
                    if #available(macOS 13.0, *) {
                        Section(header: Text("文字")) {
                            TextEditor(text: $style.textString)
                                .frame(height: 200)
                                .focused($isFocusedOnTextEditor)
                                .border(.gray, width: 1)
                                .scrollDisabled(true) // macOS 13.0以上でしか使えない
                                .padding(.top, 3)
                                .padding(.bottom, spacing)
                                .onChange(of: style.textString, perform: { value in
                                    pathFactory.pathHistory.applyStyleToSelectedPath(style)
                                })
                        }
                    } else {
                        Section(header: Text("文字")) {
                            TextEditor(text: $style.textString)
                                .frame(height: 200)
                                .focused($isFocusedOnTextEditor)
                                .border(.gray, width: 1)
                                .padding(.top, 3)
                                .padding(.bottom, spacing)
                                .onChange(of: style.textString, perform: { value in
                                    pathFactory.pathHistory.applyStyleToSelectedPath(style)
                                })
                        }
                    }
                }
                
                if $style.isEraser.wrappedValue {
                    Text("エフェクトの上でクリックすると、\nそのエフェクトを削除します。")
                        .padding(.bottom, spacing)
                }
                
                Spacer()
            }
            .padding(.vertical, 10)
        }
    }
}

struct PenToolStylePanel_Previews: PreviewProvider {
    static var previews: some View {
        PenToolStylePanelPerType(type: .arrow)
    }
}
