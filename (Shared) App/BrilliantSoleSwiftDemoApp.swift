//
//  BrilliantSoleSwiftDemoApp.swift
//  BrilliantSoleSwiftDemo
//
//  Created by Zack Qattan on 1/15/25.
//

import SwiftUI

@main
struct BrilliantSoleSwiftDemoApp: App {
    init() {
        #if !os(visionOS) && !os(tvOS)
            DeviceMetadataManager.shared.clear()
            DiscoveredDeviceMetadataManager.shared.clear()
        #endif
    }

    @Environment(\.scenePhase) private var phase

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
