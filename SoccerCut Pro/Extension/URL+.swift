//
//  URL+.swift
//  SoccerCut Pro
//
//  Created by Naoki Tanaka on 2023/06/02.
//

import Cocoa

extension URL {
    var pathMacOSVersionFree: String {
        if #available(macOS 13.0, *) { return path(percentEncoded: false) }
        else { return path }
    }
    
    func getFilenameWith(suffix: String, removeExtension: Bool) -> String {
        let filename = self.lastPathComponent
        let extWithDot = "." + self.pathExtension
        let hasExtInFilename = filename.hasSuffix(extWithDot)
        
        if !hasExtInFilename { return filename + "_" + suffix }
        
        let filenameWithoutExt = filename.dropLast(extWithDot.count)
        
        if removeExtension { return filenameWithoutExt + "_" + suffix }
        return filenameWithoutExt + "_" + suffix + extWithDot
    }
}
