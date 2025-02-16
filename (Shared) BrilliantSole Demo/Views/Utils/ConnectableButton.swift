//
//  ConnectableButton.swift
//  BrilliantSoleSwiftDemo
//
//  Created by Zack Qattan on 2/16/25.
//

import BrilliantSole
import Combine
import SwiftUI

struct ConnectableButton: View {
    private let connectable: BSConnectable
    @State private var connectionStatus: BSConnectionStatus = .notConnected

    let includeConnectionType: Bool

    init(connectable: BSConnectable, includeConnectionType: Bool = false) {
        self.connectable = connectable
        self.includeConnectionType = includeConnectionType
    }

    private var connectionTypeName: String {
        switch connectable.connectionType {
        case nil:
            "unknown"
        default:
            connectable.connectionType!.name
        }
    }

    @State private var connectingAnimationAmount: CGFloat = 1

    var body: some View {
        HStack {
            if connectionStatus == .connected || connectionStatus == .disconnecting {
                if includeConnectionType {
                    Text("connected via \(connectionTypeName)")
                }
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
            }
        }
        .onReceive(connectable.connectionStatusPublisher) { newConnectionStatus in
            connectionStatus = newConnectionStatus
        }
    }
}

#Preview {
    ConnectableButton(connectable: BSDevice.mock)
    #if os(macOS)
        .frame(maxWidth: 350, minHeight: 300)
    #endif
}
