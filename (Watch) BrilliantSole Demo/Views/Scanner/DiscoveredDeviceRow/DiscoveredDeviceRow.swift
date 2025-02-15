//
//  DiscoveredDeviceRow.swift
//  BrilliantSoleSwiftDemo
//
//  Created by Zack Qattan on 2/13/25.
//

import BrilliantSole
import Combine
import SwiftUI

struct DiscoveredDeviceRow: View {
    let discoveredDevice: BSDiscoveredDevice
    @State private var deviceCreated = false

    var body: some View {
        Group {
            if deviceCreated, let device = discoveredDevice.device {
                DeviceRow(device: device)
            }
            else {
                VStack {
                    DiscoveredDeviceRowHeader(discoveredDevice: discoveredDevice)
                    DiscoveredDeviceRowConnection(discoveredDevice: discoveredDevice)
                    DiscoveredDeviceRowStatus(discoveredDevice: discoveredDevice)
                }
                .padding()
            }
        }
        .onReceive(discoveredDevice.devicePublisher) { _, device in
            deviceCreated = device != nil
        }
    }
}

#Preview {
    DiscoveredDeviceRow(discoveredDevice: .none)
#if os(macOS)
        .frame(maxWidth: 350, minHeight: 300)
#endif
}
