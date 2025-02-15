//
//  DeviceRowConnection.swift
//  BrilliantSoleSwiftDemo
//
//  Created by Zack Qattan on 2/13/25.
//

import BrilliantSole
import SwiftUI

struct DeviceRowConnection: View {
    let device: BSDevice
    let onSelectDevice: (() -> Void)?

    @State private var connectionStatus: BSConnectionStatus = .notConnected
    @State private var connectingAnimationAmount: CGFloat = 1

    private var connectionTypeName: String {
        switch device.connectionType {
        case nil:
            "unknown"
        default:
            device.connectionType!.name
        }
    }

    init(device: BSDevice, onSelectDevice: (() -> Void)? = nil) {
        self.device = device
        self.onSelectDevice = onSelectDevice
        _connectionStatus = .init(initialValue: connectionStatus)
    }

    var body: some View {
        HStack {
            if connectionStatus == .connected || connectionStatus == .disconnecting {
                Text("connected via \(connectionTypeName)")
                Button(role: .destructive, action: {
                    device.disconnect()
                }, label: {
                    Text("disconnect")
                })
                .buttonStyle(.borderedProminent)
                #if !os(visionOS)
                    .tint(.red)
                #endif
                if !is_iOS {
                    Spacer()
                }
            }
            else {
                if connectionStatus == .notConnected {
                    Text("connect via:")
                    Button(action: {
                        device.connect()
                    }, label: {
                        Text(connectionTypeName)
                            .accessibilityLabel("connect via \(connectionTypeName)")
                    })
                    .buttonStyle(.borderedProminent)
                }
                else {
                    if is_iOS {
                        Spacer()
                    }
                    Button(role: .cancel, action: {
                        device.disconnect()
                    }, label: {
                        Text("connecting...")
                            .accessibilityLabel("cancel connection")
                    })
                    .buttonStyle(.borderedProminent)
                    .scaleEffect(connectingAnimationAmount)
                    .animation(
                        .easeInOut(duration: 0.5)
                            .repeatForever(autoreverses: true),
                        value: connectingAnimationAmount)
                    .onAppear {
                        connectingAnimationAmount = 0.97
                    }
                    .onDisappear {
                        connectingAnimationAmount = 1
                    }
                }

                Spacer()
            }
        }
        .onReceive(device.connectionStatusPublisher, perform: { _, newConnectionStatus in
            connectionStatus = newConnectionStatus
        })
    }
}

#Preview {
    DeviceRowConnection(device: .none)
    #if os(macOS)
        .frame(maxWidth: 350, minHeight: 300)
    #endif
}
