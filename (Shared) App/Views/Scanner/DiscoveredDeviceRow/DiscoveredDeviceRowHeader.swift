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

    var body: some View {
        DeviceRowHeader(metaDevice: discoveredDevice)
    }
}

#Preview {
    DiscoveredDeviceRowHeader(discoveredDevice: .none)
    #if os(macOS)
        .frame(maxWidth: 350, minHeight: 300)
    #endif
}
