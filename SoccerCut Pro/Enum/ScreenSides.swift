//
//  ScreenMode.swift
//  SoccerCut Pro
//
//  Created by Naoki Tanaka on 2023/05/23.
//

public enum ScreenSides: Int {
    case left = 0
    case right = 1
    case both = 2
    
    var nextIfToggleScreen1: ScreenSides {
        return self == .left ? .both : .left
    }
    
    var nextIfToggleScreen2: ScreenSides {
        return self == .right ? .both : .right
    }
    
    var theOtherSide: ScreenSides? {
        if self == .both { return nil }
        return self == .left ? .right : .left
    }
}
