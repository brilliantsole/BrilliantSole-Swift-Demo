//
//  DeviceRowConnection.swift
//  BrilliantSoleSwiftDemo
//
//  Created by Zack Qattan on 2/13/25.
//

import BrilliantSole
import SwiftUI

struct DeviceRowConnection: View {
    let connectable: BSConnectable
    let includeConnectionType: Bool

    @State private var connectionStatus: BSConnectionStatus = .notConnected
    @State private var connectingAnimationAmount: CGFloat = 1

    private var connectionTypeName: String {
        switch connectable.connectionType {
        case nil:
            "unknown"
        default:
            connectable.connectionType!.name
        }
    }

    init(connectable: BSConnectable, includeConnectionType: Bool = false) {
        self.connectable = connectable
        self.includeConnectionType = includeConnectionType
        _connectionStatus = .init(initialValue: connectionStatus)
    }

    var body: some View {
        HStack {
            if connectionStatus == .connected || connectionStatus == .disconnecting {
                Text("connected via \(connectionTypeName)")
                Button(role: .destructive, action: {
                    connectable.disconnect()
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
                    if includeConnectionType {
                        Text("connect via:")
                        Button(action: {
                            connectable.connect()
                        }, label: {
                            Text(connectionTypeName)
                                .accessibilityLabel("connect via \(connectionTypeName)")
                        })
                        .buttonStyle(.borderedProminent)
                    }
                    else {
                        Button("connect") {
                            connectable.connect()
                        }
                        .buttonStyle(.borderedProminent)
                    }
                }
                else {
                    if is_iOS {
                        Spacer()
                    }
                    Button(role: .cancel, action: {
                        connectable.disconnect()
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
        .onReceive(connectable.connectionStatusPublisher, perform: { newConnectionStatus in
            connectionStatus = newConnectionStatus
        })
    }
}

#Preview {
    DeviceRowConnection(connectable: BSDevice.mock)
    #if os(macOS)
        .frame(maxWidth: 350, minHeight: 300)
    #endif
}
