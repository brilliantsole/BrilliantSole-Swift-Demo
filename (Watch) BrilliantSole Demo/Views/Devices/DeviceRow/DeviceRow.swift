//
//  DeviceRow.swift
//  BrilliantSoleSwiftDemo
//
//  Created by Zack Qattan on 2/13/25.
//

import BrilliantSole
import SwiftUI

struct DeviceRow: View {
    let device: BSDevice
    var onSelectDevice: (() -> Void)?

    @State private var isConnected: Bool = false

    var body: some View {
        VStack {
            if isConnected {
                Button(action: {
                    onSelectDevice?()
                }) {
                    DeviceRowHeader(metaDevice: device)
                }
                .buttonStyle(.borderedProminent)

            } else {
                DeviceRowHeader(metaDevice: device)
            }
            DeviceRowConnection(connectable: device)
            DeviceRowStatus(device: device)
        }
        .padding()
        .onReceive(device.isConnectedPublisher) { newIsConnected in
            isConnected = newIsConnected
        }
    }
}

#Preview {
    DeviceRow(device: .mock)
    #if os(macOS)
        .frame(maxWidth: 350, minHeight: 300)
    #endif
}
