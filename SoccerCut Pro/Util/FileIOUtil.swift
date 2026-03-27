//
//  FileIOUtil.swift
//  SoccerCut Pro
//
//  Created by Naoki Tanaka on 2023/06/03.
//

import Cocoa

class FileIOUtil {    
    static func openTextFileAndWrite(text: String) {
        let openPanel = NSOpenPanel()
        openPanel.allowedContentTypes = [.text]
        openPanel.allowsMultipleSelection = false

        let modalResponse = openPanel.runModal()
        if modalResponse == .OK {
            guard let url = openPanel.url else { return }
            
            let path = url.pathMacOSVersionFree
            
            do {
                try text.write(toFile: path, atomically: true, encoding: .utf8)
                print("ログ書き込み成功: ", path)

            } catch {
                print("ログ書き込み成功失敗: ", error )
            }
        }
    }
}
