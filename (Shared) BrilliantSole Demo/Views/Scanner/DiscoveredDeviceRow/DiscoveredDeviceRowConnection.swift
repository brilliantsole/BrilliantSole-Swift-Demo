//
//  DiscoveredDeviceRowConnection.swift
//  BrilliantSoleSwiftDemo
//
//  Created by Zack Qattan on 2/13/25.
//

import BrilliantSole
import Combine
import SwiftUI

struct DiscoveredDeviceRowConnection: View {
    let discoveredDevice: BSDiscoveredDevice
    var cancellables: Set<AnyCancellable> = []

    var body: some View {
        Button(action: {
            _ = discoveredDevice.connect()
        }, label: {
            Text("connect")
        })
        .buttonStyle(.borderedProminent)
    }
}

#Preview {
    DiscoveredDeviceRowConnection(discoveredDevice: .none)
    #if os(macOS)
        .frame(maxWidth: 350, minHeight: 300)
    #endif
}
