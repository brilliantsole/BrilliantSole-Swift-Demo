//
//  Device.swift
//  BrilliantSoleSwiftDemo
//
//  Created by Zack Qattan on 2/18/25.
//

import BrilliantSole
import Combine
import SwiftUI

struct DeviceView: View {
    let device: BSDevice

    @EnvironmentObject var navigationManager: NavigationManager

    var body: some View {
        List {
            DeviceInformationSection(device: device)
            InformationSection(device: device)
            BatterySection(device: device)
            ExamplesSection(device: device)
        }
        .navigationTitle(device.name)
        .onReceive(device.isConnectedPublisher) { isConnected in
            if !isConnected && !device.isMock {
                navigationManager.resetNavigation()
            }
        }
        .navigationDestination(for: Example.self) { example in
            example.view(device: device)
        }
    }
}

#Preview {
    @Previewable @StateObject var navigationManager = NavigationManager()

    let device: BSDevice = .mock

    NavigationStack(path: $navigationManager.path) {
        DeviceView(device: device)
    }
    .environmentObject(navigationManager)
    #if os(macOS)
        .frame(maxWidth: 350, maxHeight: 300)
    #endif
}
