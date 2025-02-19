//
//  Device.swift
//  BrilliantSoleSwiftDemo
//
//  Created by Zack Qattan on 2/18/25.
//

import BrilliantSole
import Combine
import SwiftUI

struct Device: View {
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
            if !isConnected {
                navigationManager.goBack()
            }
        }
    }
}

#Preview {
    NavigationStack {
        Device(device: .mock)
    }
    .environmentObject(NavigationManager())
    #if os(macOS)
        .frame(maxWidth: 350, minHeight: 300)
    #endif
}
