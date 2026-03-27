//
//  CIImage+.swift
//  SoccerCut Pro
//
//  Created by Naoki Tanaka on 2023/10/02.
//

import Cocoa

extension CIImage {
    func writeToPng(to fileUrl: URL) throws {
        guard let pngData = CIContext().pngRepresentation(
            of: self,
            format: .RGBA8,
            colorSpace: self.colorSpace ?? CGColorSpaceCreateDeviceRGB(),
            options: [:]) else {
                // PNGデータ作成失敗
                return
        }
        try pngData.write(to: fileUrl)
    }
    
    func writeToJpeg(to fileUrl: URL) throws {
        guard let jpegData = CIContext().jpegRepresentation(
            of: self,
            colorSpace: self.colorSpace ?? CGColorSpaceCreateDeviceRGB(),
            options: [:]) else {
                // JPEGデータ作成失敗
                return
        }
        try jpegData.write(to: fileUrl)
    }
    
    func pixelBuffer(cgSize size:CGSize) -> CVPixelBuffer? {
        let width = Int(size.width)
        let height = Int(size.height)
        let attrs = [kCVPixelBufferCGImageCompatibilityKey: kCFBooleanTrue,
                     kCVPixelBufferCGBitmapContextCompatibilityKey: kCFBooleanTrue] as CFDictionary

        var pixelBuffer: CVPixelBuffer?
        CVPixelBufferCreate(kCFAllocatorDefault,
                            width,
                            height,
                            kCVPixelFormatType_32BGRA,
                            attrs,
                            &pixelBuffer)

        // put bytes into pixelBuffer
        let context = CIContext()
        context.render(self, to: pixelBuffer!)
        return pixelBuffer
    }
}
