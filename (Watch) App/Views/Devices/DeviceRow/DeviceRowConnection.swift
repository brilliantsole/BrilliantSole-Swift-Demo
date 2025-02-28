//
//  DeviceRowConnection.swift
//  BrilliantSoleSwiftDemo
//
//  Created by Zack Qattan on 2/13/25.
//

import BrilliantSole
import SwiftUI

struct DeviceRowConnection: View {
    @State private var connectedDeviceCount: Int = 0
    @State private var connectionStatus: BSConnectionStatus = .notConnected

    let connectable: BSConnectable
    var body: some View {
        Group {
            ConnectableButton(connectable: connectable)
                .disabled(connectedDeviceCount >= 2 && connectionStatus == .notConnected)
        }
        .onReceive(BSDeviceManager.connectedDevicesPublisher) { connectedDevices in
            connectedDeviceCount = connectedDevices.count
        }
        .onReceive(connectable.connectionStatusPublisher) { newConnectionStatus in
            connectionStatus = newConnectionStatus
        }
    }
}

#Preview {
    DeviceRowConnection(connectable: BSDevice.mock)
    #if os(macOS)
        .frame(maxWidth: 350, minHeight: 300)
    #endif
}
