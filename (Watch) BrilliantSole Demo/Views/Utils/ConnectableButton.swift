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
    let connectable: BSConnectable

    @State private var connectionStatus: BSConnectionStatus = .notConnected
    @State private var connectingAnimationAmount: CGFloat = 1
    @Namespace private var animation

    private var connectionTypeName: String {
        switch connectable.connectionType {
        case nil:
            "unknown"
        default:
            connectable.connectionType!.name
        }
    }

    var body: some View {
        VStack {
            if connectionStatus == .connected || connectionStatus == .disconnecting {
                Button(role: .destructive, action: {
                    connectable.disconnect()
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
                        connectable.connect()
                    }, label: {
                        Text("connect")
                    })
                    .matchedGeometryEffect(id: "Button", in: animation)
                    .buttonStyle(.borderedProminent)
                    .tint(.blue)
                }
                else {
                    Button(role: .cancel, action: {
                        connectable.disconnect()
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
        .onReceive(connectable.connectionStatusPublisher, perform: { newConnectionStatus in
            connectionStatus = newConnectionStatus
        })
    }
}

#Preview {
    ConnectableButton(connectable: BSDevice.mock)
    #if os(macOS)
        .frame(maxWidth: 350, minHeight: 300)
    #endif
}
