//
//  Devices.swift
//  BrilliantSoleSwiftDemo
//
//  Created by Zack Qattan on 2/13/25.
//

import BrilliantSole
import SwiftUI

struct Devices: View {
    @EnvironmentObject var navigationManager: NavigationManager

    @State private var devices: [BSDevice] = .init()

    var body: some View {
        NavigationStack(path: $navigationManager.path) {
            List {
                if devices.isEmpty {
                    if devices.isEmpty {
                        HStack {
                            Spacer()
                            Text("no devices available")
                            Spacer()
                        }
                    }
                }
                else {
                    ForEach(devices) { device in
                        DeviceRow(device: device)
                            .id(device.id)
                    }
                }
            }
            .navigationTitle("Devices")
        }
        .onReceive(BSDeviceManager.availableDevicesPublisher) { devices in
            self.devices = devices
        }
    }
}

#Preview {
    Devices()
        .environmentObject(NavigationManager())
    #if os(macOS)
        .frame(maxWidth: 350, minHeight: 300)
    #endif
}
