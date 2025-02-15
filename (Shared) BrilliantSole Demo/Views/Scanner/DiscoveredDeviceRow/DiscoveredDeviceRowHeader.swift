//
//  DiscoveredDeviceRowHeader.swift
//  BrilliantSoleSwiftDemo
//
//  Created by Zack Qattan on 2/13/25.
//

import BrilliantSole
import SwiftUI

struct DiscoveredDeviceRowHeader: View {
    let discoveredDevice: BSDiscoveredDevice

    @State private var name: String = ""
    @State private var deviceType: BSDeviceType? = nil

    var body: some View {
        GenericDeviceRowHeader(name: name, deviceType: deviceType)
            .onReceive(discoveredDevice.deviceTypePublisher) { _, newDeviceType in
                deviceType = newDeviceType
            }
            .onReceive(discoveredDevice.namePublisher) { _, newName in
                name = newName
            }
    }
}

#Preview {
    DiscoveredDeviceRowHeader(discoveredDevice: .none)
    #if os(macOS)
        .frame(maxWidth: 350, minHeight: 300)
    #endif
}
