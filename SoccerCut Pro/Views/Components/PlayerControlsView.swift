//
//  PlayerControlsView.swift
//  SoccerCut Pro
//
//  Created by Naoki Tanaka on 2023/05/24.
//

import AVFoundation
import SwiftUI

struct PlayerControlsView: View {
    @ObservedObject var playerViewModel: PlayerViewModel
    @State private var controlsOffset: CGSize = .zero
    @State private var dragStartPosition: CGPoint = .zero
    @State private var isDragging = false
    @State private var isHover = false
    
    init(playerViewModel: PlayerViewModel) {
        self.playerViewModel = playerViewModel
    }
    
    var drag: some Gesture {
        DragGesture()
            .onChanged { gesture in
                if isDragging == false {
                    dragStartPosition = CGPoint(x: controlsOffset.width, y: controlsOffset.height)
                    isDragging = true
                }
                controlsOffset =  CGSize(width: gesture.translation.width + dragStartPosition.x,
                                         height: gesture.translation.height + dragStartPosition.y)
            }
            .onEnded { _ in
                isDragging = false
            }
    }
        
    var body: some View {
        Group {
            VStack(spacing: 0) {
               
                ZStack {
                    // 音量調節ボタンとスライダー
                    HStack {
                        ButtonDynamicIcon(size: 20, imgName: $playerViewModel.muteSoundImgName) {
                            playerViewModel.onClickMuteSoundBtn()
                        }
                        VolumeSlider(playerViewModel: playerViewModel)
                        Spacer()
                    }
                    
                    HStack {
                        // 巻き戻し
                        Text(playerViewModel.rewindLabelValue)
                            .frame(width: 50, alignment: .trailing)
                            .foregroundColor(.white)
                        ButtonStaticIcon(size: 20, imgName: "backward.fill") {
                            playerViewModel.onClickRewindBtn()
                        }
                        
                        // 再生・一時停止
                        ButtonDynamicIcon(size: 30, imgName: $playerViewModel.playPauseImgName) {
                            playerViewModel.onClickPlayPauseBtn()
                        }
                        
                        // 早送り
                        ButtonStaticIcon(size: 20, imgName: "forward.fill") {
                            playerViewModel.onClickSkipBtn()
                        }
                        Text(playerViewModel.skipLabelValue)
                            .frame(width: 50, alignment: .leading)
                            .foregroundColor(.white)
                    }
                    
                    HStack {
                        Spacer()
                        ButtonStaticIcon(size: 20, imgName: "pencil.and.outline") {
                            playerViewModel.onClickPencilButton()
                        }
                    }
                }
                
                ZStack {
                    // トリミング開始位置
                    Triangle()
                        .frame(width: 20, height: 20)
                        .offset(x: playerViewModel.trimmingStartMarkerOffsetX, y: 0)
                        .rotationEffect(Angle(degrees: 180))
                        .foregroundColor(.orange)
                        .opacity(playerViewModel.isShownTrimmingMarker ? 1.0 : 0.0)
                    
                    // トリミング終了位置
                    Triangle()
                        .frame(width: 20, height: 20)
                        .offset(x: playerViewModel.trimmingEndMarkerOffsetX, y: 0)
                        .rotationEffect(Angle(degrees: 180))
                        .foregroundColor(.orange)
                        .opacity(playerViewModel.isShownTrimmingMarker ? 1.0 : 0.0)
                }
                
                SeekBar(playerViewModel: playerViewModel)
            }
            .padding(10)
            .background(Color.gray)
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .offset(controlsOffset)
            .background(GeometryReader{ geometry -> Text in
                // rootViewから見た位置(Position)とサイズ
                var frame = geometry.frame(in: .global)
                // offsetを考慮
                frame.origin = frame.origin + CGPoint(x: controlsOffset.width, y: controlsOffset.height)
                playerViewModel.ctrlsFrame = frame
                return Text("") // ダミー
            })
            .gesture(drag)
            .padding(.horizontal, 10)
            .opacity(playerViewModel.showControls ? 1.0 : 0.0)
        }
        .position(x: playerViewModel.viewFrame.size.width/2, y: playerViewModel.viewFrame.size.height - 100) // 初期位置を設定
        .frame(maxWidth: playerViewModel.viewFrame.size.width, maxHeight: playerViewModel.viewFrame.size.height)
    }
}

struct PlayerControls_Previews: PreviewProvider {
    static var previews: some View {
        PlayerControlsView(playerViewModel: PlayerViewModel())
    }
}

