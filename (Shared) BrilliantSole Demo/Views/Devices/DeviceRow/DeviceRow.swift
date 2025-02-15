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
            HStack {
                DeviceRowHeader(device: device)
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
            DeviceRowConnection(device: device)
            #if os(tvOS)
                .focusSection()
            #endif
            DeviceRowStatus(device: device)
        }
        .onReceive(device.isConnectedPublisher) { _, newIsConnected in
            isConnected = newIsConnected
        }
        .padding()
        #if os(tvOS)
            .focusSection()
        #endif
    }
}

#Preview {
    DeviceRow(device: .none)
    #if os(macOS)
        .frame(maxWidth: 350, minHeight: 300)
    #endif
}
