//
//  DualSwitchesView.swift
//  SoccerCut Pro
//
//  Created by Naoki Tanaka on 2023/06/02.
//

import SwiftUI

struct DualSwitchesView: View {
    @ObservedObject var playersViewModel: PlayersViewModel
    
    init(playersViewModel: PlayersViewModel) {
        self.playersViewModel = playersViewModel
    }
        
    var body: some View {
        Group {
            HStack {
                if playersViewModel.bothPlayersHaveLoadedFile {
                    ButtonDynamicIcon(size: 20,
                                      imgName: .constant("speaker.wave.2.bubble.left.fill"),
                                      isFlippedX: $playersViewModel.audioSideImgIsFilppedX) {
                        playersViewModel.onClickSwitchAudioBtn()
                    }
                    
                    ButtonDynamicIcon(size: 20,
                                      imgName: $playersViewModel.syncModeImgName,
                                      subImgName: .constant("play.fill")) {
                        playersViewModel.onClickSwitchSyncModeBtn()
                    }
                }
                
                ButtonDynamicIcon(size: 20,
                                  imgName: $playersViewModel.fullScreenModeImgName,
                                  isFlippedX: .constant(true)) {
                    playersViewModel.onClickSwitchFullScreenModeBtn()
                }
            }
            .padding(10)
            .background(Color.gray)
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .background(GeometryReader{ geometry -> Text in
                            playersViewModel.switchesFrameInPlayersView = geometry.frame(in: .global)
                            return Text("") // ダミー
                        })
            .padding(.horizontal, 10)
            .opacity(playersViewModel.showDualSwitches ? 1.0 : 0.0)
        }
        .position(x: playersViewModel.bothPlayersHaveLoadedFile
                        ? playersViewModel.viewFrame.size.width - 65
                        : playersViewModel.viewFrame.size.width - 30,
                  y: 30)
    }
}

struct DualSwitches_Previews: PreviewProvider {
    static var previews: some View {
        DualSwitchesView(playersViewModel: PlayersViewModel())
    }
}
