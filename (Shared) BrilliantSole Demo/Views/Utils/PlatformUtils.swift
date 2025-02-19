//
//  PlatformUtils.swift
//  BrilliantSoleSwiftDemo
//
//  Created by Zack Qattan on 2/10/25.
//

import SwiftUI

var isWatch: Bool {
    #if os(watchOS)
    true
    #else
    false
    #endif
}

var isTv: Bool {
    #if os(tvOS)
    true
    #else
    false
    #endif
}

var isMacOs: Bool {
    #if os(macOS)
    true
    #else
    false
    #endif
}

var is_iOS: Bool {
    #if os(iOS)
    true
    #else
    false
    #endif
}

var isVisionOS: Bool {
    #if os(visionOS)
    true
    #else
    false
    #endif
}

var isPreview: Bool {
    return ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1"
}
