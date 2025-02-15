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
                    DeviceRowHeader(device: device)
                }
                .buttonStyle(.borderedProminent)

            } else {
                DeviceRowHeader(device: device)
            }
            DeviceRowConnection(device: device)
            DeviceRowStatus(device: device)
        }
        .id(device.id)
        .padding()
        .onReceive(device.isConnectedPublisher) { _, newIsConnected in
            isConnected = newIsConnected
        }
    }
}

#Preview {
    DeviceRow(device: .none)
    #if os(macOS)
        .frame(maxWidth: 350, minHeight: 300)
    #endif
}
