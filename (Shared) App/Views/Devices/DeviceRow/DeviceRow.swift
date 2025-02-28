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
            HStack {
                DeviceRowHeader(metaDevice: device)
                Spacer()
                if isConnected {
                    Button(action: {
                        onSelectDevice?()
                        navigationManager.navigateTo(device)
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
            DeviceRowConnection(connectable: device, includeConnectionType: includeConnectionType)
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
        .environmentObject(NavigationManager())
    #if os(macOS)
        .frame(maxWidth: 350, minHeight: 300)
    #endif
}
