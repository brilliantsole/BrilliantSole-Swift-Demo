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
    let onSelectDevice: (() -> Void)?

    @State private var isConnected: Bool = false

    init(device: BSDevice, onSelectDevice: (() -> Void)? = nil) {
        self.device = device
        self.onSelectDevice = onSelectDevice
        _isConnected = .init(initialValue: isConnected)
    }

    var body: some View {
        VStack {
            HStack {
                DeviceRowHeader(metaDevice: device)
                Spacer()
                if isConnected {
                    Button(action: {
                        onSelectDevice?()
                    }) {
                        Label("select", systemImage: "chevron.right.circle")
                            .labelStyle(LabelSpacing(spacing: 4))
                    }
                    .buttonStyle(.borderedProminent)
                }
            }
            #if os(tvOS)
            .focusSection()
            #endif
            DeviceRowConnection(connectable: device, includeConnectionType: true)
            #if os(tvOS)
                .focusSection()
            #endif
            DeviceRowStatus(device: device)
        }
        .onReceive(device.isConnectedPublisher) { newIsConnected in
            isConnected = newIsConnected
        }
        .padding()
        #if os(tvOS)
            .focusSection()
        #endif
    }
}

#Preview {
    DeviceRow(device: .mock)
    #if os(macOS)
        .frame(maxWidth: 350, minHeight: 300)
    #endif
}
