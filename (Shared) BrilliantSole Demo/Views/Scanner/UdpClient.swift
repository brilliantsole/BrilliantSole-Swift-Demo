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

    private var labelWidth: CGFloat {
        if isTv {
            return 170
        }
        else if isMacOs {
            return 100
        }
        else {
            return 100
        }
    }

    var body: some View {
        VStack {
            HStack {
                Text("__Ip Address__")
                    .frame(width: labelWidth, alignment: .leading)
                TextField("Ip Address", text: $ipAddress)
                #if !os(tvOS)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                #endif
                    .modify {
                        #if os(iOS) || os(tvOS) || os(visionOS)
                            $0.keyboardType(.decimalPad)
                        #endif
                    }
                    .onChange(of: ipAddress) { _, newValue in
                        isIpAddressValid = client.isValidIpAddress(newValue)
                        if isIpAddressValid {
                            client.ipAddress = newValue
                        }
                    }
                    .foregroundColor(isIpAddressValid ? .primary : .red)
            }

            HStack {
                Text("__Send Port__")
                    .frame(width: labelWidth, alignment: .leading)
                TextField("Send Port", value: $sendPort, format: .number.grouping(.never))
                #if !os(tvOS)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                #endif
                    .onChange(of: sendPort) { _, newValue in
                        client.sendPort = newValue
                    }
            }

            HStack {
                Text("__Receive Port__")
                    .frame(width: labelWidth, alignment: .leading)
                TextField("Receive Port", value: $receivePort, format: .number.grouping(.never))
                #if !os(tvOS)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                #endif
                    .onChange(of: receivePort) { _, newValue in
                        client.receivePort = newValue
                    }
            }
        }
        .disabled(connectionStatus != .notConnected)
        .onReceive(client.connectionStatusPublisher) { newConnectionStatus in
            connectionStatus = newConnectionStatus
        }

        HStack {
            ConnectableButton(connectable: client)
            Spacer()
        }
    }
}

#Preview {
    List {
        UdpClient()
    }
    #if os(macOS)
    .frame(maxWidth: 350, minHeight: 300)
    #endif
}
