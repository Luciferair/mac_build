//
//  PenToolEditHistoryPanel.swift
//  SoccerCut Pro
//
//  Created by Naoki Tanaka on 2023/08/16.
//

import SwiftUI

struct PenToolEditPanel: View {
    @ObservedObject private(set) var viewModel = PenToolEditViewModel()
    @FocusState private var isFocused: Bool
    static let backgroundColor: Color = .gray
    private let numberFormatter = NumberFormatter()
    private let effectSecsMin = 0.1
    private let effectSecsMax = 10.0
    
    init() {
        numberFormatter.maximumFractionDigits = 1
        numberFormatter.minimum = NSNumber(value: effectSecsMin)
        numberFormatter.maximum = NSNumber(value: effectSecsMax)
    }
        
    var body: some View {
        HStack(alignment: .center, spacing: 10) {
            PenToolEditButton(systemImageName: "arrow.uturn.left") { viewModel.undo() }
                .disabled(!viewModel.canUndo)
            PenToolEditButton(systemImageName: "arrow.uturn.right") { viewModel.redo() }
                .disabled(!viewModel.canRedo)
            
            Spacer()
            
            HStack(spacing: 0) {
                Text("エフェクト秒数：")
                    .foregroundColor(.white)
                TextField("", value: $viewModel.currentFrameEffectSecs, formatter: numberFormatter)
                    .frame(width: 30)
                    .focused($isFocused)
                Stepper("", onIncrement: {
                    isFocused = false
                    if viewModel.currentFrameEffectSecs <= effectSecsMax - 0.5 { viewModel.currentFrameEffectSecs += 0.5 }
                }, onDecrement: {
                    isFocused = false
                    if viewModel.currentFrameEffectSecs > 0.5 { viewModel.currentFrameEffectSecs -= 0.5 }
                })
            }
            .padding(.horizontal, 10)
            
            PenToolEditButton(systemImageName: "camera") { viewModel.takeScreenshot() }
                .disabled(!viewModel.canClearAll) // takeScreenshotとclearAllは実行可能条件が同じはずなので使い回し
            PenToolEditButton(systemImageName: "play.display") { viewModel.preview() }
                .disabled(!viewModel.canPreview)
            PenToolEditButton(systemImageName: "square.and.arrow.down") { viewModel.save() }
                .disabled(!viewModel.canPreview) // previewとsaveは実行可能条件が同じはずなので使い回し
            
            Spacer()
            
            PenToolEditButton(systemImageName: "trash") { viewModel.clearAll() }
                .disabled(!viewModel.canClearAll)
        }
        .padding(.horizontal, 10)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(PenToolEditPanel.backgroundColor)
    }
}

struct EditHistoryPanel_Previews: PreviewProvider {
    static var previews: some View {
        PenToolEditPanel()
    }
}
