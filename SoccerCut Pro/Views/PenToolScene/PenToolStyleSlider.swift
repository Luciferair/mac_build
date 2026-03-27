//
//  PenToolStyleSlider.swift
//  SoccerCut Pro
//
//  Created by Naoki Tanaka on 2023/11/08.
//

import SwiftUI

struct PenToolStyleSlider: View {
    @Binding var value: Int32
    private let minValue: Int32
    private let maxValue: Int32
    private let step: Int32
    private let showValueLabel: Bool

    init(value: Binding<Int32>, minValue: Int32, maxValue: Int32, step: Int32, showValueLabel: Bool = true) {
        self._value = value
        self.minValue = minValue
        self.maxValue = maxValue
        self.step = step
        self.showValueLabel = showValueLabel
    }
    
    var body: some View {
        HStack {
            StyleSlider(value: $value, minValue: minValue, maxValue: maxValue, step: step)
            if showValueLabel {
                Text(String(value))
                    .frame(width: 20, height: 10)
                    .padding(.leading, -5)
            }
        }
    }
}

private struct StyleSlider: NSViewRepresentable {
    @Binding var value: Int32
    private let minValue: Int32
    private let maxValue: Int32
    private let step: Int32
    
    init(value: Binding<Int32>, minValue: Int32, maxValue: Int32, step: Int32) {
        self._value = value
        self.minValue = minValue
        self.maxValue = maxValue
        self.step = step
    }

    func makeNSView(context: Context) -> NSSlider {
        let slider = NSSlider()
        slider.cell = MYSliderCell()
        slider.sliderType = .linear
        slider.isEnabled = true
        slider.isContinuous = true
        slider.altIncrementValue = Double(step)
        slider.intValue = value
        slider.minValue = Double(minValue)
        slider.maxValue = Double(maxValue)
        slider.target = context.coordinator
        slider.action = #selector(context.coordinator.changed(_:))
        return slider
    }

    func updateNSView(_ slider: NSSlider, context: NSViewRepresentableContext<StyleSlider>) {
        slider.intValue = value
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(value: $value)
    }

    final class Coordinator: NSObject {
        @Binding var value: Int32

        init(value: Binding<Int32>) {
            self._value = value
        }

        @objc func changed(_ sender: NSSlider) {
            self.value = sender.intValue
        }
    }
}

private class MYSliderCell: NSSliderCell {

    override func drawBar(inside rect: NSRect, flipped: Bool) {
        var rect = rect
        rect.size.height = CGFloat(4)
        let value = CGFloat((self.doubleValue - self.minValue) / (self.maxValue - self.minValue))
        let leftWidth = CGFloat(value * (self.controlView!.frame.size.width - 8))

        var leftRect = rect
        leftRect.size.width = leftWidth
        let leftPath = NSBezierPath(roundedRect: leftRect, xRadius: CGFloat(2), yRadius: CGFloat(2))
        NSColor.controlAccentColor.setFill()
        leftPath.fill()

        let backgroundPath = NSBezierPath(roundedRect: rect, xRadius: CGFloat(2), yRadius: CGFloat(2))
        NSColor.lightGray.withAlphaComponent(0.3).setFill()
        backgroundPath.fill()
    }
}

struct PenToolStyleSlider_Previews: PreviewProvider {
    static var previews: some View {
        EmptyView()
    }
}
