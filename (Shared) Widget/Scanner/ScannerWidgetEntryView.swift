//
//  ScannerWidgetEntryView.swift
//  BrilliantSoleSwiftDemo
//
//  Created by Zack Qattan on 2/28/25.
//

import AppIntents
import BrilliantSole
import SwiftUI
import WidgetKit

struct ScannerWidgetEntryView: View {
    var entry: ScannerWidgetProvider.Entry

    @Environment(\.widgetFamily) var family

    private var discoveredDeviceMetadataManager: DiscoveredDeviceMetadataManager { .shared }
    private var isScanning: Bool { discoveredDeviceMetadataManager.isScanning }
    private var discoveredDeviceIds: [String] { discoveredDeviceMetadataManager.ids }

    private var deviceMetadataManager: DeviceMetadataManager { .shared }
    private var deviceIds: [String] { deviceMetadataManager.ids }

    var spacing: CGFloat = 12

    @ViewBuilder
    var scanButton: some View {
        let text = discoveredDeviceMetadataManager.isScanning ? "scanning" : "scan"
        let imageName = discoveredDeviceMetadataManager.isScanning ? "antenna.radiowaves.left.and.right" : "antenna.radiowaves.left.and.right.slash"
        let label = Label(text, systemImage: imageName)
            .labelStyle(.iconOnly)
        let intent = BSToggleScanIntent(connectionTypeName: BSConnectionType.ble.name)
        Button(intent: intent) {
            label
        }
    }

    var body: some View {
        HStack {
            Text("BrilliantSole Devices")
                .font(.title2)
            Spacer()
            scanButton
        }

        if isScanning {
            HStack {
                Spacer()
                Text("scanning for devices...")
                    .font(.caption)
                Spacer()
            }
        }
        if discoveredDeviceIds.isEmpty {
            if !isScanning {
                HStack {
                    Spacer()
                    Text("no devices found")
                        .font(.caption)
                    Spacer()
                }
            }
        }
        if !discoveredDeviceIds.isEmpty {
            VStack {
                ForEach(discoveredDeviceIds, id: \.self) {
                    ScannerDeviceRow(id: $0)
                    Divider()
                }
            }
        }
        Spacer()
    }
}
