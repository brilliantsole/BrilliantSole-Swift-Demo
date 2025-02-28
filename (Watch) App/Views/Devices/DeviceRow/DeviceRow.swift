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

    @State private var isConnected: Bool = false

    let includeConnectionType: Bool

    @EnvironmentObject var navigationManager: NavigationManager
    var onSelectDevice: (() -> Void)?

    init(device: BSDevice, includeConnectionType: Bool = false, onSelectDevice: (() -> Void)? = nil) {
        self.device = device
        self.includeConnectionType = includeConnectionType
        _isConnected = .init(initialValue: isConnected)
        self.onSelectDevice = onSelectDevice
    }

    var body: some View {
        VStack {
            if isConnected {
                Button(action: {
                    onSelectDevice?()
                    navigationManager.navigateTo(device)
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
        .environmentObject(NavigationManager())
    #if os(macOS)
        .frame(maxWidth: 350, minHeight: 300)
    #endif
}
