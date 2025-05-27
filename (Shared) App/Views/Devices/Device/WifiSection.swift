//
//  WifiSection.swift
//  BrilliantSoleSwiftDemo
//
//  Created by Zack Qattan on 5/25/25.
//

import BrilliantSole
import Combine
import SwiftUI

struct WifiSection: View {
    let device: BSDevice

    var canEdit: Bool {
        !isWatch && !isTv && !isWifiConnected
    }

    @State private var wifiSSID: String
    @State private var newWifiSSID: String = ""

    @State private var wifiPassword: String
    @State private var newWifiPassword: String = ""

    @State private var wifiConnectionEnabled: Bool = false

    @State private var isWifiConnected: Bool = false

    @State private var ipAddress: String?

    @State private var isWifiSecure: Bool = false

    init(device: BSDevice) {
        self.device = device
        _wifiSSID = .init(initialValue: device.wifiSSID)
        _wifiPassword = .init(initialValue: device.wifiPassword)

        _wifiConnectionEnabled = .init(initialValue: device.wifiConnectionEnabled)

        _isWifiConnected = .init(initialValue: device.isWifiConnected)
        _ipAddress = .init(initialValue: device.ipAddress)
        _isWifiSecure = .init(initialValue: device.isWifiSecure)
    }

    var body: some View {
        Section {
            HStack {
                Text("__wifi SSID:__")
                Text(wifiSSID)
                #if os(iOS)
                    .textSelection(.enabled)
                #endif
            }
            .onReceive(device.wifiSSIDPublisher) {
                self.wifiSSID = $0
            }
            if canEdit {
                HStack {
                    TextField("new wifi SSID", text: $newWifiSSID)
                        .autocorrectionDisabled()
                    Button(action: {
                        device.setWifiSSID(newWifiSSID)
                        newWifiSSID = ""
                    }) {
                        Text("update")
                    }
                    .disabled(newWifiSSID.isEmpty)
                }
            }

            HStack {
                Text("__wifi Password:__")
                Text(wifiPassword)
                #if os(iOS)
                    .textSelection(.enabled)
                #endif
            }
            .onReceive(device.wifiPasswordPublisher) {
                self.wifiPassword = $0
            }
            if canEdit {
                HStack {
                    TextField("new wifi password", text: $newWifiPassword)
                        .autocorrectionDisabled()
                    Button(action: {
                        device.setWifiPassword(newWifiPassword)
                        newWifiSSID = ""
                    }) {
                        Text("update")
                    }
                    .disabled(newWifiPassword.isEmpty)
                }
            }

            Text("__wifi connection enabled?__ \(wifiConnectionEnabled ? "Yes" : "No")")
                .onReceive(device.wifiConnectionEnabledPublisher) { wifiConnectionEnabled = $0 }

            Button(wifiConnectionEnabled ? "disable connection" : "enable connection") {
                device.toggleWifiConnection()
            }

            Text("__wifi connected?__ \(isWifiConnected ? "Yes" : "No")")
                .onReceive(device.isWifiConnectedPublisher) { isWifiConnected = $0 }

            Group {
                if isWifiConnected, let ipAddress {
                    Text("__ip address:__ \(ipAddress)")
                }
            }.onReceive(device.ipAddressPublisher) { ipAddress = $0 }

            if isWifiConnected {
                Text("__is wifi secure?__ \(isWifiSecure ? "Yes" : "No")")
                    .onReceive(device.isWifiSecurePublisher) { isWifiSecure = $0 }
            }

        } header: {
            Text("Wifi")
                .font(.headline)
        }
    }
}

#Preview {
    List {
        WifiSection(device: .mock)
    }
    #if os(macOS)
    .frame(maxWidth: 410, minHeight: 300)
    #endif
}
