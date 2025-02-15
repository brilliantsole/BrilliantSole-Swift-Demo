//
//  DiscoveredDeviceRowStatus.swift
//  BrilliantSoleSwiftDemo
//
//  Created by Zack Qattan on 2/13/25.
//

import BrilliantSole
import SwiftUI

struct DiscoveredDeviceRowStatus: View {
    @State private var isScanning: Bool = false

    let discoveredDevice: BSDiscoveredDevice

    @State private var rssi: Int? = nil
    @State private var timeSinceLastUpdate: TimeInterval?

    var body: some View {
        let layout = isWatch ? AnyLayout(VStackLayout()) : AnyLayout(HStackLayout(spacing: 15))

        layout {
            if isScanning {
                HStack(spacing: 15) {
                    if let rssi {
                        Label(String(format: "%3d", rssi), systemImage: "cellularbars")
                    }

                    if let timeSinceLastUpdateString = discoveredDevice.timeSinceLastUpdateString {
                        Label(timeSinceLastUpdateString, systemImage: "stopwatch")
                    }
                }
                .onReceive(discoveredDevice.rssiPublisher, perform: { _, newRssi in
                    rssi = newRssi
                })
                .onReceive(discoveredDevice.timeSinceLastUpdatePublisher, perform: { _, newTimeSinceLastUpdate in
                    timeSinceLastUpdate = newTimeSinceLastUpdate
                })
            }
        }
        .onReceive(discoveredDevice.scanner.isScanningPublisher, perform: {
            isScanning = $0
        })
        .labelStyle(LabelSpacing(spacing: 4))
        .font(Font.system(isWatch ? .caption2 : .caption, design: .monospaced))
        .padding(.top, 2)
    }
}

#Preview {
    DiscoveredDeviceRowStatus(discoveredDevice: .none)
    #if os(macOS)
        .frame(maxWidth: 350, minHeight: 300)
    #endif
}
