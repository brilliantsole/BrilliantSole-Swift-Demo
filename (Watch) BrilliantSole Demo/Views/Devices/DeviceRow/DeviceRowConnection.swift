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
    var onSelectDevice: (() -> Void)?

    @State private var connectionStatus: BSConnectionStatus = .notConnected
    @State private var connectingAnimationAmount: CGFloat = 1
    @Namespace private var animation

    private var connectionTypeName: String {
        switch device.connectionType {
        case nil:
            "unknown"
        default:
            device.connectionType!.name
        }
    }

    var body: some View {
        VStack {
            if connectionStatus == .connected || connectionStatus == .disconnecting {
                Button(role: .destructive, action: {
                    device.disconnect()
                }, label: {
                    Text("disconnect")
                })
                .matchedGeometryEffect(id: "Button", in: animation)
                .tint(.red)
                .buttonStyle(.borderedProminent)
            }
            else {
                if connectionStatus == .notConnected {
                    Button(action: {
                        device.connect()
                    }, label: {
                        Text("connect")
                    })
                    .matchedGeometryEffect(id: "Button", in: animation)
                    .buttonStyle(.borderedProminent)
                    .tint(.blue)
                }
                else {
                    Button(role: .cancel, action: {
                        device.disconnect()
                    }, label: {
                        Text("connecting...")
                            .accessibilityLabel("cancel connection")
                    })
                    .matchedGeometryEffect(id: "Button", in: animation)
                    .tint(.cyan)
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
