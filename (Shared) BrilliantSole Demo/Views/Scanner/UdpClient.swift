//
//  UdpClient.swift
//  BrilliantSoleSwiftDemo
//
//  Created by Zack Qattan on 2/15/25.
//

import BrilliantSole
import Combine
import SwiftUI

struct UdpClient: View {
    private let client: BSUdpClient = .shared
    @State private var ipAddress: String
    @State private var isIpAddressValid: Bool = false

    @State private var sendPort: UInt16
    @State private var receivePort: UInt16

    @State private var connectionStatus: BSConnectionStatus = .notConnected

    init() {
        _ipAddress = .init(initialValue: client.ipAddress)
        _sendPort = .init(initialValue: client.sendPort)
        _receivePort = .init(initialValue: client.receivePort)

        _isIpAddressValid = .init(initialValue: client.isValidIpAddress(ipAddress))

        _connectionStatus = .init(initialValue: client.connectionStatus)
    }

    var body: some View {
        Form {
            Section {
                Group {
                    HStack {
                        TextField("Ip Address", text: $ipAddress)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .modify {
                                #if os(iOS) || os(tvOS) || os(visionOS)
                                    $0.keyboardType(.decimalPad)
                                #endif
                            }
                            .onChange(of: ipAddress) { _, newValue in
                                isIpAddressValid = client.isValidIpAddress(newValue)
                            }
                            .foregroundColor(isIpAddressValid ? .primary : .red)
                    }

                    HStack {
                        TextField("Send Port", value: $sendPort, format: .number.grouping(.never))
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }

                    HStack {
                        TextField("Receive Port", value: $receivePort, format: .number.grouping(.never))
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }
                }
                .disabled(connectionStatus != .notConnected)
                .onReceive(client.connectionStatusPublisher) { newConnectionStatus in
                    connectionStatus = newConnectionStatus
                }

                ConnectableButton(connectable: client)
            }
        }
    }
}

#Preview {
    UdpClient()
    #if os(macOS)
        .frame(maxWidth: 350, minHeight: 300)
    #endif
}
