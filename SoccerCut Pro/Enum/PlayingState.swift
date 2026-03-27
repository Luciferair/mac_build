//
//  PlayingState.swift
//  SoccerCut Pro
//
//  Created by Naoki Tanaka on 2023/05/27.
//

import Cocoa

enum PlayingState: Float {
    case play = 1.0
    case pause = 0.0
    case skip2x = 2.0
    case skip5x = 5.0
    case skip10x = 10.0
    case skip30x = 30.0
    case rewind2x = -2.0
    case rewind5x = -5.0
    case rewind10x = -10.0
    case rewind30x = -30.0
    
    var rewindLabel: String! {
        switch self {
        case .rewind2x: return "2x"
        case .rewind5x: return "5x"
        case .rewind10x: return "10x"
        case .rewind30x: return "30x"
        default: return ""
        }
    }
    
    var skipLabel: String! {
        switch self {
        case .skip2x: return "2x"
        case .skip5x: return "5x"
        case .skip10x: return "10x"
        case .skip30x: return "30x"
        default: return ""
        }
    }
    
    var rateIfRewind: Float! {
        switch self {
        case .rewind2x: return PlayingState.rewind5x.rawValue
        case .rewind5x: return PlayingState.rewind10x.rawValue
        case .rewind10x: return PlayingState.rewind30x.rawValue
        case .rewind30x: return PlayingState.rewind2x.rawValue
        default: return PlayingState.rewind2x.rawValue
        }
    }
    
    var rateIfSkip: Float! {
        switch self {
        case .skip2x: return PlayingState.skip5x.rawValue
        case .skip5x: return PlayingState.skip10x.rawValue
        case .skip10x: return PlayingState.skip30x.rawValue
        case .skip30x: return PlayingState.skip2x.rawValue
        default: return PlayingState.skip2x.rawValue
        }
    }
    
    var isSkip: Bool {
        switch self {
        case .skip2x: return true
        case .skip5x: return true
        case .skip10x: return true
        case .skip30x: return true
        default: return false
        }
    }
    
    var isRewind: Bool {
        switch self {
        case .rewind2x: return true
        case .rewind5x: return true
        case .rewind10x: return true
        case .rewind30x: return true
        default: return false
        }
    }
}
