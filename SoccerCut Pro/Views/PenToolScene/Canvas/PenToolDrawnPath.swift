//
//  PenToolDrawnPath.swift
//  SoccerCut Pro
//
//  Created by Naoki Tanaka on 2023/08/05.
//

import SwiftUI

struct PenToolDrawnPath: View, Identifiable {
    @ObservedObject private var viewModel = PenToolDrawnPathViewModel()
    
    let id: Int
    let type: PenToolType
    private var path: any PenToolPathProtocol
    // 破線のスタート地点を変更する為のプロパティ
    @State private var dashPhase: CGFloat = 0
    // Timerのカウントを保持するプロパティ
    @State private var timerCount: CGFloat = 0
    // 0.1秒毎にdashPhaseを変更処理を実行する為のTimer
    private let timer = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()
    
    var isSelected: Bool { get { return viewModel.isSelected } }
    private var styleWatchTimer: Timer?
    
    init(id: Int, type: PenToolType, path: any PenToolPathProtocol) {
        self.id = id
        self.type = type
        self.path = path
    }
    
    func drawnStyle() -> PenToolPathStyle { return path.drawnStyle() }
    func applyStyle(_ newStyle: PenToolPathStyle) { path.applyStyle(newStyle) }
    func drawnTransform() -> PenToolPathTransform { return path.drawnTransform() }
    func applyTransform(_ newTransform: PenToolPathTransform) { path.applyTransform(newTransform) }
    
    func setIsSelected(_ isSelected: Bool) {
        viewModel.isSelected = isSelected
    }
        
    var drag: some Gesture {
        DragGesture(minimumDistance: 0)
            .onChanged { value in
                if !viewModel.isSelected {
                    viewModel.isSelected = true
                    NotificationCenter.default.post(name: .clickedDrawnPathNotification, object: nil, userInfo: ["pathId": id])
                }
                path.onDragged(startInVideoRect: value.startLocation, endInVideoRect: value.location)
            }
            .onEnded { value in
                path.onDragEnded(startInVideoRect: value.startLocation, endInVideoRect: value.location)
            }
    }
        
    var body: some View {
        // GeometryReaderを使うとなぜかframeの位置とサイズがバグる問題が解決するので使っておく
        GeometryReader { geometry in
            ZStack {
                AnyView(path)
                    .if(type == viewModel.currentType()) {
                        $0.contentShape(Rectangle())
                    }
//                    .border(.blue, width: 3)
                    .offset(path.offset())
                    .frame(width: path.frame().width, height: path.frame().height)
                    .gesture(drag)
                
                if viewModel.isSelected {
                    Rectangle()
                        .stroke(style: StrokeStyle(lineWidth: 3, dash: [6, 6], dashPhase: dashPhase))
                        .offset(path.offset())
                        .frame(width: path.frame().width, height: path.frame().height)
                        .onReceive(timer) { _ in
                            timerCount = timerCount > 10 ? 0 : timerCount + 1
                            dashPhase = timerCount
                        }
                }
            }
        }
    }
}

struct PenToolPath_Previews: PreviewProvider {
    static var previews: some View {
        EmptyView()
    }
}
