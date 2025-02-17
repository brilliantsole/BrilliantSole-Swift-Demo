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

    init(discoveredDevice: BSDiscoveredDevice) {
        self.discoveredDevice = discoveredDevice
        _deviceCreated = .init(initialValue: discoveredDevice.device != nil)
    }

    var body: some View {
        Group {
            if deviceCreated, let device = discoveredDevice.device {
                DeviceRow(device: device)
                    .transition(.opacity.combined(with: .scale))
            } else {
                VStack {
                    HStack {
                        DiscoveredDeviceRowHeader(discoveredDevice: discoveredDevice)
                        Spacer()
                    }
#if os(tvOS)
                    .focusSection()
#endif
                    DiscoveredDeviceRowConnection(discoveredDevice: discoveredDevice)
#if os(tvOS)
                        .focusSection()
#endif
                    DiscoveredDeviceRowStatus(discoveredDevice: discoveredDevice)
                }
                .padding()
#if os(tvOS)
                    .focusSection()
#endif
            }
        }
        .animation(.default, value: deviceCreated)
        .onReceive(discoveredDevice.devicePublisher) { device in
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
