//
//  PenToolStylePanel.swift
//  SoccerCut Pro
//
//  Created by Naoki Tanaka on 2023/08/11.
//

import AppKit
import SwiftUI

/// NSTextView wrapper that properly claims and holds first-responder status,
/// preventing the macOS menu/keyboard shortcut system from intercepting
/// key events (Space, arrow keys, etc.) while the user is typing text.
private struct FocusableTextEditor: NSViewRepresentable {
    @Binding var text: String
    var onTextChange: (String) -> Void

    func makeNSView(context: Context) -> NSScrollView {
        let textView = FirstResponderTextView()
        textView.delegate = context.coordinator
        textView.isEditable = true
        textView.isSelectable = true
        textView.allowsUndo = true
        textView.isRichText = false
        textView.font = NSFont.systemFont(ofSize: NSFont.systemFontSize)
        textView.string = text
        textView.isVerticallyResizable = true
        textView.isHorizontallyResizable = false
        textView.autoresizingMask = [.width]
        textView.textContainer?.widthTracksTextView = true
        textView.textContainer?.containerSize = NSSize(
            width: CGFloat.greatestFiniteMagnitude,
            height: CGFloat.greatestFiniteMagnitude
        )

        let scrollView = NSScrollView()
        scrollView.documentView = textView
        scrollView.hasVerticalScroller = false
        scrollView.hasHorizontalScroller = false
        scrollView.borderType = .bezelBorder
        scrollView.autohidesScrollers = true
        return scrollView
    }

    func updateNSView(_ scrollView: NSScrollView, context: Context) {
        guard let textView = scrollView.documentView as? NSTextView else { return }
        // Only update if changed externally to avoid resetting cursor
        if textView.string != text {
            textView.string = text
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(text: $text, onTextChange: onTextChange)
    }

    final class Coordinator: NSObject, NSTextViewDelegate {
        var text: Binding<String>
        let onTextChange: (String) -> Void
        init(text: Binding<String>, onTextChange: @escaping (String) -> Void) {
            self.text = text
            self.onTextChange = onTextChange
        }
        func textDidChange(_ notification: Notification) {
            guard let textView = notification.object as? NSTextView else { return }
            // Write the new value back to the binding so the model stays in sync
            text.wrappedValue = textView.string
            onTextChange(textView.string)
        }
    }

    /// Custom NSTextView that overrides acceptsFirstResponder so the
    /// macOS responder chain never bypasses it for menu key equivalents.
    private class FirstResponderTextView: NSTextView {
        override var acceptsFirstResponder: Bool { true }
        override func becomeFirstResponder() -> Bool {
            let result = super.becomeFirstResponder()
            return result
        }
        // Consume all key-down events so they never bubble up to menu shortcuts
        override func keyDown(with event: NSEvent) {
            // Let the text view handle the key normally
            super.keyDown(with: event)
        }
        // Override performKeyEquivalent to prevent menu shortcuts from stealing
        // plain key events (Space, letters, etc.) while typing in the text view.
        override func performKeyEquivalent(with event: NSEvent) -> Bool {
            guard window?.firstResponder == self else {
                return super.performKeyEquivalent(with: event)
            }
            // Allow Cmd+key combos (copy/paste/undo) to pass through normally
            if event.modifierFlags.contains(.command) {
                return super.performKeyEquivalent(with: event)
            }
            // For plain keys or shift-only keys, consume the event here and
            // feed it to the text input system so typing works normally.
            self.keyDown(with: event)
            return true
        }
    }
}

struct PenToolStylePanelPerType: View {
    @State private var type: PenToolType
    @ObservedObject private(set) var pathFactory: PenToolPathFactory
    @ObservedObject private(set) var style: PenToolPathStyle
    @ObservedObject private var recentColors = RecentColors.shared
    
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
                    Section(header: Text(type == .connectedCircles ? "円の輪郭の太さ" : "線の太さ")) {
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
                
                if $style.useConnectorLineWidth.wrappedValue {
                    Section(header: Text("接続線の太さ")) {
                        PenToolStyleSlider(value: $style.connectorLineWidth, minValue: 1, maxValue: 40, step: 1)
                            .padding(.horizontal, 10)
                            .padding(.bottom, spacing)
                            .onChange(of: style.connectorLineWidth, perform: { value in
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
                    
                    Section(header: Text("文字")) {
                            FocusableTextEditor(text: $style.textString) { newValue in
                                pathFactory.pathHistory.applyStyleToSelectedPath(style)
                            }
                            .frame(height: 200)
                            .padding(.top, 3)
                            .padding(.bottom, spacing)
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
