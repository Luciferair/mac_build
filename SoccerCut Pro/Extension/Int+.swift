//
//  Int+.swift
//  SoccerCut Pro
//
//  Created by Naoki Tanaka on 2023/05/29.
//

import Cocoa

extension Int {
    func formatToHHMMSS() -> String? {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute, .second]
        formatter.unitsStyle = .positional
        formatter.zeroFormattingBehavior = [ .pad ]
        
        return formatter.string(from: TimeInterval(self))
    }
}
