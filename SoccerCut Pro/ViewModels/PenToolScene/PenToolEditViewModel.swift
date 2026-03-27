//
//  PenToolEditHistoryViewModel.swift
//  SoccerCut Pro
//
//  Created by Naoki Tanaka on 2023/09/11.
//

import AVFoundation
import Cocoa
import SwiftUI

class PenToolEditViewModel: ObservableObject {
    private var processingStateHolder: PenToolProcessingViewStateHolder
    private let player: PenToolPlayer
    private let pathFactory: PenToolPathFactory
    private let pathHistory: PenToolPathHistory
    private let thumbnails: PenToolEffectThumbnailsModel
    private let frameEffectSecsKeyString = "penToolFrameEffectSeconds"
    private var currentFrameEffectSecsPrev: Double = 0.0
    @Published var currentFrameEffectSecs: Double
    @Published private(set) var canUndo: Bool = false
    @Published private(set) var canRedo: Bool = false
    @Published private(set) var canClearAll: Bool = false
    @Published private(set) var canPreview: Bool = false
    private var previewFileUrl: URL? = nil
    
    init() {
        processingStateHolder = PenToolModel.now.processingStateHolder
        player = PenToolModel.now.player
        pathFactory = PenToolModel.now.pathFactory
        pathHistory = PenToolModel.now.pathHistory
        thumbnails = PenToolModel.now.effectThumbnails
        
        // 初回起動時にはUserDefaultsKeyが保存されていないため、初期値を設定しておく。
        UserDefaults.standard.register(defaults: [frameEffectSecsKeyString : 5.0])
        // 前回のエフェクト表示秒数を読み込み
        currentFrameEffectSecs = UserDefaults.standard.double(forKey: frameEffectSecsKeyString)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.onDrawnPathChange), name: .drawnPathDidChangeNotification, object: pathHistory)
        
        let timeInterval = 0.2
        Timer.scheduledTimer(withTimeInterval: timeInterval, repeats: true, block: { (timer) in
            // UIから変更があった
            if self.currentFrameEffectSecs != self.currentFrameEffectSecsPrev {
                self.pathHistory.changeShowingEffectSecs(newSecs: self.currentFrameEffectSecs)
            }
            // Modelから変更があった（undo/redo等）
            else if self.currentFrameEffectSecs != self.pathHistory.currentShowingEffectSecsSetting {
                self.currentFrameEffectSecs = self.pathHistory.currentShowingEffectSecsSetting
            }
            
            self.currentFrameEffectSecsPrev = self.currentFrameEffectSecs
        })
    }
    
    @objc func onDrawnPathChange() {
        canUndo = !pathHistory.steps.isEmpty
        canRedo = !pathHistory.undoneSteps.isEmpty
        canClearAll = !pathHistory.currentTargetFrameDrawns.isEmpty
        canPreview = !pathHistory.currentTargetFrameDrawns.isEmpty || !pathHistory.drawnsWithoutCurrentTargetFrame.isEmpty
        previewFileUrl = nil
    }
    
    func undo() { pathHistory.undo() }
    func redo() { pathHistory.redo() }
    func clearAll() { pathHistory.clearAll() }
    
    func takeScreenshot() {
        pathHistory.clearSelectedStateOfPath()
        
        AppDelegate.instance.switchUndoRedo(isGeneral: true)
        defer { AppDelegate.instance.switchUndoRedo(isGeneral: false) }
        
        // 保存先URLをポップアップで取得
        let savePanel = NSSavePanel()
        if #available(macOS 11.0, *) {
            savePanel.allowedContentTypes = [.png]
        } else {
            savePanel.allowedFileTypes = ["png"]
        }
        savePanel.isExtensionHidden = false
        let dt = Date()
        let df = DateFormatter()
        df.dateFormat = "yyyyMMdd_HHmmss"
        savePanel.nameFieldStringValue = player.fileUrl.getFilenameWith(suffix: df.string(from: dt), removeExtension: true)
        
        AppDelegate.instance.switchPlayerStepAndSkipRewind(isEnabled: false)
        let modalResponse = savePanel.runModal()
        AppDelegate.instance.switchPlayerStepAndSkipRewind(isEnabled: pathFactory.currentType != .text)
        
        if modalResponse == .OK {
            guard let exportUrl = savePanel.url else { return }
            
            Task { @MainActor in
                processingStateHolder.setCurrent(.indicator, processType: .screenshot)
                do {
                    // スクリーンショット(CIImage)を生成
                    let screenshotCIImage = try await createScreenshot(frameSecs: pathHistory.currentTargetFrame.seconds, drawnPaths: pathHistory.currentTargetFrameDrawns)
                    // CIImageをJPEG形式で保存
                    try screenshotCIImage.writeToPng(to: exportUrl)
                    // Assetのエクスポート処理をしていないので、statusCodeを手動で入力
                    processingStateHolder.statusCode = .completed
                } catch {
                    processingStateHolder.errorMsg = error.localizedDescription
                    processingStateHolder.statusCode = nil
                }
                processingStateHolder.setCurrent(.dialog, processType: .screenshot)
            }
        }
    }
    
    func preview() {
        pathHistory.clearSelectedStateOfPath()
        
        UserDefaults.standard.setValue(currentFrameEffectSecs, forKey: frameEffectSecsKeyString)
        UserDefaults.standard.synchronize()
        
        Task { @MainActor in
            processingStateHolder.setCurrent(.indicator, processType: .preview)
            
            do {
                // 静止画から動画を生成
                let frozenMovies = try await createFrozenFrameMovieFromThumbnailAndPaths()
                // 動画を合成
                previewFileUrl = try await combineMovieAndPaths(frozenFrameMovies: frozenMovies)
                print(previewFileUrl)
                
                // ファイルの存在確認後、動画をプレーヤーで開く
                if previewFileUrl != nil && FileManager.default.fileExists(atPath: previewFileUrl!.pathMacOSVersionFree) {
                    openMovieFile(fileUrl: previewFileUrl!)
                }
                
            } catch {
                processingStateHolder.errorMsg = error.localizedDescription
                processingStateHolder.statusCode = nil
            }
            
            processingStateHolder.setCurrent(.dialog, processType: .preview)
        }
    }
    
    func save() {
        pathHistory.clearSelectedStateOfPath()
        
        AppDelegate.instance.switchUndoRedo(isGeneral: true)
        defer { AppDelegate.instance.switchUndoRedo(isGeneral: false) }
        
        UserDefaults.standard.setValue(currentFrameEffectSecs, forKey: frameEffectSecsKeyString)
        UserDefaults.standard.synchronize()
        
        // 保存先URLをポップアップで取得
        let savePanel = NSSavePanel()
        if #available(macOS 11.0, *) {
            savePanel.allowedContentTypes = [.movie]
        } else {
            savePanel.allowedFileTypes = ["movie"]
        }
        savePanel.isExtensionHidden = false
        let dt = Date()
        let df = DateFormatter()
        df.dateFormat = "yyyyMMdd_HHmmss"
        savePanel.nameFieldStringValue = player.fileUrl.getFilenameWith(suffix: df.string(from: dt), removeExtension: false)
        
        AppDelegate.instance.switchPlayerStepAndSkipRewind(isEnabled: false)
        let modalResponse = savePanel.runModal()
        AppDelegate.instance.switchPlayerStepAndSkipRewind(isEnabled: pathFactory.currentType != .text)
        
        if modalResponse == .OK {
            guard let exportUrl = savePanel.url else { return }
            
            Task { @MainActor in
                processingStateHolder.setCurrent(.indicator, processType: .save)
                do {
                    // 直前にプレビュー動画を生成していなければ生成
                    if previewFileUrl == nil {
                        // 静止画から動画を生成
                        let frozenMovies = try await createFrozenFrameMovieFromThumbnailAndPaths()
                        // 動画を合成
                        previewFileUrl = try await combineMovieAndPaths(frozenFrameMovies: frozenMovies)
                        // 動画を指定されたパスに移動
                        try FileManager.default.moveItem(atPath: previewFileUrl!.pathMacOSVersionFree, toPath: exportUrl.pathMacOSVersionFree)
                    } else {
                        // プレビュー動画を指定されたパスに移動
                        try FileManager.default.moveItem(atPath: previewFileUrl!.pathMacOSVersionFree, toPath: exportUrl.pathMacOSVersionFree)
                        // エクスポート処理をしていないので、statusCodeを手動で入力
                        processingStateHolder.statusCode = .completed
                    }
                    
                    // ファイルの存在確認後、動画をプレーヤーモードで開く
                    if FileManager.default.fileExists(atPath: exportUrl.pathMacOSVersionFree) {
                        openMovieFile(fileUrl: exportUrl)
                    }
                    
                } catch {
                    processingStateHolder.errorMsg = error.localizedDescription
                    processingStateHolder.statusCode = nil
                }
                processingStateHolder.setCurrent(.dialog, processType: .save)
            }
        }
    }
    
    private func openMovieFile(fileUrl: URL) {
        // playerライセンスあり -> プレーヤーモードで開く
        if ValidTransactions.instance.isEligibleFor(appMode: .player) {
            let storyboard = NSStoryboard(name: "Main", bundle: nil)
            guard let windowController = storyboard.instantiateController(withIdentifier: "PlayersWindowID") as? MainWindowController,
                  let viewController = windowController.contentViewController as? MainViewController else { return }
            viewController.doubleClickedFileUrl = fileUrl
            windowController.showWindow(self)
        } else {
            let defaultAppUrlOfMp4 = NSWorkspace.shared.urlForApplication(toOpen: .mpeg4Movie)
            let bundleUrl = Bundle.main.bundleURL
            let quickTimePlayerAppUrl = URL(string: "file:///System/Applications/QuickTime%20Player.app/")
            if defaultAppUrlOfMp4 == bundleUrl {
                // playerライセンスなし&SoccerCut Proがデフォルトアプリである -> QuickTime Playerで開く
                if quickTimePlayerAppUrl != nil {
                    NSWorkspace.shared.open([fileUrl], withApplicationAt: quickTimePlayerAppUrl!,
                                            configuration: NSWorkspace.OpenConfiguration()) {app, error in }
                }
            } else {
                // playerライセンスなし&SoccerCut Proがデフォルトアプリでない -> デフォルトアプリで開く
                NSWorkspace.shared.open([fileUrl], withApplicationAt: defaultAppUrlOfMp4 ?? quickTimePlayerAppUrl!,
                                        configuration: NSWorkspace.OpenConfiguration()) {app, error in }
            }
        }
        
        //        // TODO playerライセンスなし&SoccerCut Proがデフォルトアプリである -> ライセンス選択画面にしたい
        //        let defaultAppUrlOfMp4 = NSWorkspace.shared.urlForApplication(toOpen: .mpeg4Movie)
        //        let bundleUrl = Bundle.main.bundleURL
        //        if defaultAppUrlOfMp4 == bundleUrl {
        //            Products.instance.selection()
        //            return
        //        }
    }
    
    private func createScreenshot(frameSecs: Double, drawnPaths: [PenToolDrawnPath]) async throws -> CIImage {
        // Paths([View])を1つのViewにまとめる
        let drawnPathsView = await PenToolDrawnPathsCompositer(paths: drawnPaths, resolution: self.player.resolution)
        
        // Paths(View)->CGImage->CIImageに変換
        var pathsCGImage: CGImage?
        if #available(macOS 13.0, *) {
            pathsCGImage = await ImageRenderer(content: drawnPathsView).cgImage
        } else {
            pathsCGImage = await drawnPathsView.nsImage()!.cgImage
        }
        guard let pathsCGImage else { throw NSError(domain: "Couldn't get pathsCGImage.", code: -1, userInfo: nil) }
        let pathsCIImage = CIImage(cgImage: pathsCGImage)
        
        // Thumbnail(CGImage->CIImage)の上にPaths(CIImage)を重ねて1つのCIImageにする
        let thumbnailCIImage = CIImage(cgImage: self.thumbnails.cgImage(at: frameSecs)!)
        let screenshotCIImage = pathsCIImage.composited(over: thumbnailCIImage)
        
        return screenshotCIImage
    }
    
    private func createFrozenFrameMovieFromThumbnailAndPaths() async throws -> [PenToolFrozenFrameMovie] {
        
        var allFrozenFrameMovies: [PenToolFrozenFrameMovie] = []
        
        for (frameSecs, drawnPaths) in self.pathHistory.allDrawnPaths {
            // nilにはならないはずだが一応エラー回避のため値を入れておく。0だとそれはそれでエラーが起きそうなので避ける。
            let showingEffectSecs = pathHistory.showingEffectSecsDict[frameSecs] ?? 0.1
            let frozenMovieDuration = CMTimeMakeWithSeconds(showingEffectSecs, preferredTimescale: player.fps)
            
            // pathsから該当frameのScreenshot(CIImage)を生成
            let screenshotCIImage = try await createScreenshot(frameSecs: frameSecs, drawnPaths: drawnPaths)
            
            // CIImage->CVPixelBufferに変換
            guard let pixelBuffer = screenshotCIImage.pixelBuffer(cgSize: self.player.resolution) else {
                throw NSError(domain: "Couldn't get CVPixelBuffer from CIImage.", code: -1, userInfo: nil)
            }
            
            // CVPixelBufferを使って静止画動画を作成
            // 生成した動画を保存するパス
            let fileName = "preview_" + String(format: "%09d", allFrozenFrameMovies.count) + ".mp4"
            let previewURL = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)
            
            // 既にファイルがある場合は削除
            let fileManeger = FileManager.default
            if fileManeger.fileExists(atPath: previewURL.path) {
                try! fileManeger.removeItem(at: previewURL)
            }
            
            guard let videoWriter = try? AVAssetWriter(outputURL: previewURL, fileType: AVFileType.mp4) else {
                throw NSError(domain: "Couldn't get AVAssetWriter.", code: -1, userInfo: nil)
            }
            
            let outputSettings: [String : Any] = [
                AVVideoCodecKey: AVVideoCodecType.h264,
                AVVideoWidthKey: self.player.resolution.width,
                AVVideoHeightKey: self.player.resolution.height
            ]
            
            let writerInput = AVAssetWriterInput(mediaType: AVMediaType.video, outputSettings: outputSettings)
            videoWriter.add(writerInput)
            
            let sourcePixelBufferAttributes: [String:Any] = [
                AVVideoCodecKey: Int(kCVPixelFormatType_32ARGB),
                AVVideoWidthKey: self.player.resolution.width,
                AVVideoHeightKey: self.player.resolution.height
            ]
            let adaptor = AVAssetWriterInputPixelBufferAdaptor(
                assetWriterInput: writerInput,
                sourcePixelBufferAttributes: sourcePixelBufferAttributes)
            writerInput.expectsMediaDataInRealTime = true

            // 動画生成開始
            if (!videoWriter.startWriting()) { throw NSError(domain: "Failed to start writing.", code: -1, userInfo: nil) }
            videoWriter.startSession(atSourceTime: .zero)
            defer {
                // 動画生成終了
                writerInput.markAsFinished()
                videoWriter.endSession(atSourceTime: frozenMovieDuration)
                videoWriter.finishWriting {} // do nothing
            }
            
            if !adaptor.assetWriterInput.isReadyForMoreMediaData {
                throw NSError(domain: "AssetWriterInput is not ready for more media data.", code: -1, userInfo: nil)
            }
            // この関数の呼び出しが1回（＝画像が1つ）だと再生時間が0になってしまうので、同一画像でもよいから2回呼び出す。
            if !adaptor.append(pixelBuffer, withPresentationTime: .zero) {
                throw NSError(domain: "Failed to append buffer.", code: -1, userInfo: nil)
            }
            if !adaptor.append(pixelBuffer, withPresentationTime: frozenMovieDuration) {
                throw NSError(domain: "Failed to append buffer.", code: -1, userInfo: nil)
            }
            
            allFrozenFrameMovies.append(PenToolFrozenFrameMovie(frameSecs: frameSecs, fileUrl: previewURL))
        }
        
        allFrozenFrameMovies.sort(by: {$0.frameSecs < $1.frameSecs})
        return allFrozenFrameMovies
    }
    
    private func combineMovieAndPaths(frozenFrameMovies: [PenToolFrozenFrameMovie]) async throws -> URL? {
        // 初期化
        var startCompositionTime = CMTime(value: .zero, timescale: player.fps)
        var durationSum = CMTime(value: .zero, timescale: player.fps)

        // 元動画のアセット取得
        let assetOrgMovie = AVURLAsset(url: player.fileUrl)
        let videoTrackOrg = try await assetOrgMovie.loadTracks(withMediaType: .video)[0]
        // 音声が無い動画の場合も考慮
        var audioTrackOrg: AVAssetTrack? = nil
        let audioTracksOrg = try await assetOrgMovie.loadTracks(withMediaType: .audio)
        if !audioTracksOrg.isEmpty {
            audioTrackOrg = audioTracksOrg[0]
        }
        
        // コンポジション作成
        let mixComposition = AVMutableComposition()
        // ベースとなる動画のコンポジション作成
        let compositionVideoTrack: AVMutableCompositionTrack! = mixComposition.addMutableTrack(withMediaType: .video, preferredTrackID: kCMPersistentTrackID_Invalid)
        // ベースとなる音声のコンポジション作成
        var compositionAudioTrack: AVMutableCompositionTrack? = nil
        if audioTrackOrg != nil {
            // ベースとなる音声のコンポジション作成
            compositionAudioTrack = mixComposition.addMutableTrack(withMediaType: .audio, preferredTrackID: kCMPersistentTrackID_Invalid)
        }
        
        var currentOrgSecs: Double = 0.0
        for i in 0 ..< frozenFrameMovies.count {
            let frozenMovie = frozenFrameMovies[i]
            // nilにはならないはずだが一応エラー回避のため値を入れておく。0だとそれはそれでエラーが起きそうなので避ける。
            let showingEffectSecs = pathHistory.showingEffectSecsDict[frozenMovie.frameSecs] ?? 0.1
            let frozenMovieDuration = CMTimeMakeWithSeconds(showingEffectSecs, preferredTimescale: player.fps)
            // 静止画動画同士の間の元動画を合成
            if i == 0 && frozenMovie.frameSecs == 0.0 { // 静止画動画から始まる かつ 静止画が1枚だけの場合
                // 先頭が音無しだと動画全体が音無しと判断されてしまうので、空のTimeRangeを挿入しておく
                if compositionAudioTrack != nil {
                    compositionAudioTrack!.insertEmptyTimeRange(CMTimeRangeMake(start: .zero, duration: frozenMovieDuration))
                }
            } else {
                let orgRestartTime = CMTimeMakeWithSeconds(currentOrgSecs, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
                let orgRestartDuration = CMTimeMakeWithSeconds(frozenMovie.frameSecs - currentOrgSecs, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
                try compositionVideoTrack.insertTimeRange(CMTimeRangeMake(start: orgRestartTime, duration: orgRestartDuration),
                                                          of: videoTrackOrg, at: startCompositionTime)
                if compositionAudioTrack != nil {
                    try compositionAudioTrack!.insertTimeRange(CMTimeRangeMake(start: orgRestartTime, duration: orgRestartDuration), of: audioTrackOrg!, at: startCompositionTime)
                }
                currentOrgSecs += orgRestartDuration.seconds
                startCompositionTime = startCompositionTime + orgRestartDuration
                durationSum = durationSum + orgRestartDuration
            }
            
            // 静止画動画を挿入
            let assetFrozenMovie = AVURLAsset(url: frozenMovie.fileUrl)
            let videoTrackFrozen = try await assetFrozenMovie.loadTracks(withMediaType: .video)[0]
            try compositionVideoTrack.insertTimeRange(CMTimeRangeMake(start: .zero, duration: frozenMovieDuration),
                                                      of: videoTrackFrozen, at: startCompositionTime)
            // 静止画動画には音がないのでAudioTrackには何もしない
            
            startCompositionTime = startCompositionTime + frozenMovieDuration
            durationSum = durationSum + frozenMovieDuration
        }
        
        // 静止画動画で終わりでなければ最後に残りの元動画を追加
        if frozenFrameMovies.last!.frameSecs < player.duration!.seconds {
            let orgRestartTime = CMTimeMakeWithSeconds(currentOrgSecs, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
            let orgRestartDuration = CMTimeMakeWithSeconds(player.duration!.seconds - currentOrgSecs, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
            try compositionVideoTrack.insertTimeRange(CMTimeRangeMake(start: orgRestartTime, duration: orgRestartDuration),
                                                      of: videoTrackOrg, at: startCompositionTime)
            if compositionAudioTrack != nil {
                try compositionAudioTrack!.insertTimeRange(CMTimeRangeMake(start: orgRestartTime, duration: orgRestartDuration), of: audioTrackOrg!, at: startCompositionTime)
            }
            currentOrgSecs = player.duration!.seconds
            startCompositionTime = startCompositionTime + orgRestartDuration
            durationSum = durationSum + orgRestartDuration
        }

        // 回転方向の設定
        compositionVideoTrack.preferredTransform = try await videoTrackOrg.load(.preferredTransform)
        // 動画のサイズを取得
        let videoSizeOrg = try await videoTrackOrg.load(.naturalSize)

        // 合成用コンポジション作成
        let videoComposition = AVMutableVideoComposition()
        videoComposition.renderSize = videoSizeOrg
        videoComposition.frameDuration = CMTimeMakeWithSeconds(1.0 / Double(player.fps), preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        // インストラクションを合成用コンポジションに設定
        let instruction = AVMutableVideoCompositionInstruction()
        instruction.timeRange = CMTimeRangeMake(start: .zero, duration: durationSum)
        let layerInstruction = AVMutableVideoCompositionLayerInstruction(assetTrack: compositionVideoTrack)
        instruction.layerInstructions = [ layerInstruction ]
        videoComposition.instructions = [ instruction ]
        // 動画のコンポジションをベースにAVAssetExportを生成
        guard let assetExport = AVAssetExportSession(asset: mixComposition, presetName: AVAssetExportPresetHighestQuality) else {
            throw NSError(domain: "Couldn't get AVAssetExportSettion", code: -1, userInfo: nil)
        }
        // 合成用コンポジションを設定
        assetExport.videoComposition = videoComposition

        // Bug①: explicit audio mix prevents crackling during re-encode
        if let compositionAudioTrack = compositionAudioTrack {
            let audioMixInputParams = AVMutableAudioMixInputParameters(track: compositionAudioTrack)
            audioMixInputParams.setVolume(1.0, at: .zero)
            let audioMix = AVMutableAudioMix()
            audioMix.inputParameters = [audioMixInputParams]
            assetExport.audioMix = audioMix
        }

        // エクスポートファイルの設定
        assetExport.outputURL = FileManager.default.temporaryDirectory.appendingPathComponent("preview.mp4")
        assetExport.outputFileType = .mp4
        assetExport.shouldOptimizeForNetworkUse = true

        // ファイルが存在している場合は削除しないとエラーになる
        if FileManager.default.fileExists(atPath: assetExport.outputURL!.pathMacOSVersionFree) {
            try? FileManager.default.removeItem(atPath: assetExport.outputURL!.pathMacOSVersionFree)
        }

        // エクスポート実行
        await assetExport.export()
        processingStateHolder.errorMsg = assetExport.error?.localizedDescription
        processingStateHolder.statusCode = assetExport.status

        // 一時ファイル（frozenFrameMovie）を削除
        for frozenFrameMovie in frozenFrameMovies {
            if FileManager.default.fileExists(atPath: frozenFrameMovie.fileUrl.pathMacOSVersionFree) {
                try? FileManager.default.removeItem(atPath: frozenFrameMovie.fileUrl.pathMacOSVersionFree)
            }
        }
        
        return assetExport.outputURL
    }
}
