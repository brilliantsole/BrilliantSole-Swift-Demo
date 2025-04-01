//
//  ScannerDeviceRow.swift
//  BrilliantSoleSwiftDemo
//
//  Created by Zack Qattan on 2/28/25.
//

import AppIntents
import BrilliantSole
import SwiftUI
import UkatonMacros
import WidgetKit

struct ScannerDeviceRow: View {
    var discoveredDeviceMetadata: DiscoveredDeviceMetadata
    var deviceMetadata: DeviceMetadata

    init(index: Int) {
        discoveredDeviceMetadata = DiscoveredDeviceMetadataManager.shared.getMetadata(index: index) ?? .none
        deviceMetadata = DeviceMetadataManager.shared.getMetadata(id: discoveredDeviceMetadata.id) ?? .none
    }

    init(id: String) {
        discoveredDeviceMetadata = DiscoveredDeviceMetadataManager.shared.getMetadata(id: id) ?? .none
        deviceMetadata = DeviceMetadataManager.shared.getMetadata(id: discoveredDeviceMetadata.id) ?? .none
    }

    init() {
        self.init(index: 0)
    }

    var isNone: Bool {
        discoveredDeviceMetadata.isNone
    }

    var id: String {
        discoveredDeviceMetadata.id
    }

    var connectionType: BSConnectionType? {
        deviceMetadata.connectionType
    }

    var connectionStatus: BSConnectionStatus? {
        _deviceMetadata.connectionStatus
    }

    var isConnected: Bool {
        discoveredDeviceMetadata.isConnected
    }

    var _deviceMetadata: any AppGroupDeviceMetadata {
        isConnected ? deviceMetadata : discoveredDeviceMetadata
    }

    var isCharging: Bool {
        deviceMetadata.isCharging
    }

    var deviceType: BSDeviceType {
        _deviceMetadata.deviceType
    }

    var batteryLevel: BSBatteryLevel {
        deviceMetadata.batteryLevel
    }

    var name: String {
        _deviceMetadata.name
    }

    var link: URL {
        .init(string: "brilliantsole-demo://select-device?id=\(id)")!
    }

    var emoji: String {
        switch deviceType {
        case .leftInsole, .rightInsole:
            "👟"
        case .leftGlove, .rightGlove:
            "🧤"
        case .glasses:
            "👓"
        case .generic:
            "🕹️"
        }
    }

    var batteryLevelProgress: Double {
        guard !isNone else { return .zero }
        return .init(batteryLevel) / 100
    }

    @ViewBuilder
    var batteryLevelView: some View {
        if !isNone {
            HStack(spacing: 3) {
                Text("\(batteryLevel)%")
                batteryLevelImage
            }
            .font(.caption)
        }
    }

    var batteryLevelImageString: String? {
        guard !isNone else { return nil }
        guard !isCharging else { return "battery.100.bolt" }

        return switch batteryLevel {
        case 85 ... 100:
            "battery.100"
        case 65 ... 85:
            "battery.75"
        case 35 ... 65:
            "battery.50"
        case 15 ... 35:
            "battery.25"
        default:
            "battery.0"
        }
    }

    var batteryLevelColor: Color {
        guard !isNone else { return .gray }

        return switch batteryLevel {
        case 60 ... 100:
            .green
        case 10 ... 60:
            .orange
        case 0 ... 10:
            .red
        default:
            .red
        }
    }

    @ViewBuilder
    var batteryLevelImage: some View {
        if let batteryLevelImageString {
            Image(systemName: batteryLevelImageString)
                .foregroundColor(batteryLevelColor)
        }
    }

    @Environment(\.widgetFamily) var family

    var imageName: String? {
        guard !isNone else { return nil }

        return switch deviceType {
        case .leftInsole, .rightInsole:
            "shoe.fill"
        default:
            nil
        }
    }

    private var imageScale: Image.Scale {
        switch family {
        case .systemLarge:
            .medium
        default:
            .medium
        }
    }

    @ViewBuilder
    private var image: some View {
        if let imageName {
            Image(systemName: imageName)
                .imageScale(imageScale)
                .modify {
                    if deviceType == .leftInsole {
                        $0.scaleEffect(x: -1)
                    }
                }
        }
    }

    @ViewBuilder
    var header: some View {
        let headerBody = HStack {
            image
            Text("\(name)")
        }
        if isConnected {
            Link(destination: link) {
                headerBody
            }
        }
        else {
            headerBody
        }
    }

    @ViewBuilder
    var footer: some View {
        HStack {
            if isConnected {
                HStack {
                    batteryLevelImage
                    batteryLevelView
                }
            }
        }
    }

    @ViewBuilder
    var connectionContent: some View {
        HStack {
            if connectionStatus == .connected || connectionStatus == .disconnecting {
                Button(role: .destructive, intent: BSDisconnectFromDeviceIntent(connectionId: id), label: {
                    Text("disconnect")
                })
                .buttonStyle(.borderedProminent)
                .tint(.red)
                if !is_iOS {
                    Spacer()
                }
            }
            else {
                if connectionStatus == .notConnected {
                    Button(intent: BSConnectToDeviceIntent(connectionId: id, connectionType: .ble), label: {
                        Text("connect")
                    })
                    .buttonStyle(.borderedProminent)
                }
                else {
                    if let connectionType {
                        Button(role: .cancel, intent: BSDisconnectFromDeviceIntent(connectionId: id), label: {
                            Text("connecting...")
                                .accessibilityLabel("cancel connection via \(connectionType.name)")
                        })
                        .buttonStyle(.borderedProminent)
                    }
                }
            }
        }
        .font(.caption)
    }

    var body: some View {
        HStack {
            header
            if isConnected {
                Spacer()
            }
            connectionContent
            Spacer()
            if isConnected {
                batteryLevelView
            }
        }
        .padding(2)
    }
}
