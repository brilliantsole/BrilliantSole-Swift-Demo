//
//  Scanner.swift
//  BrilliantSoleSwiftDemo
//
//  Created by Zack Qattan on 2/10/25.
//

import BrilliantSole
import SwiftUI

struct Scanner: View {
    @EnvironmentObject var navigationManager: NavigationManager

    @State private var selectedScannerType: BSConnectionType = .ble {
        didSet {
            oldValue.scanner.stopScan()
        }
    }

    private var scanner: BSScanner { selectedScannerType.scanner }
    @State private var isScanning: Bool = false
    @State private var isScanningAvailable: Bool = false

    @State private var discoveredDevices: [BSDiscoveredDevice] = .init()

    init(selectedScannerType: BSConnectionType = .ble) {
        self.selectedScannerType = selectedScannerType
        _isScanning = .init(initialValue: scanner.isScanning)
        _isScanningAvailable = .init(initialValue: scanner.isScanningAvailable)
        _discoveredDevices = .init(initialValue: scanner.discoveredDevices)
    }

    var body: some View {
        NavigationStack(path: $navigationManager.path) {
            List {
                #if !os(watchOS)
                    VStack {
                        Picker("scanner type", selection: $selectedScannerType) {
                            ForEach(BSConnectionType.allCases) { connectionType in
                                Text(connectionType.name).tag(connectionType)
                            }
                        }
                        if selectedScannerType == .udpClient {
                            UdpClient()
                        }
                    }
                #endif

                if isScanning {
                    HStack {
                        Spacer()
                        Text("scanning for devices...")
                        Spacer()
                    }
                }
                if discoveredDevices.isEmpty {
                    if !isScanning {
                        HStack {
                            Spacer()
                            Text("not scanning for devices")
                            Spacer()
                        }
                    }
                }
                else {
                    ForEach(discoveredDevices) { discoveredDevice in
                        DiscoveredDeviceRow(discoveredDevice: discoveredDevice)
                    }
                }
            }
            .navigationTitle("Scanner")
            .toolbar {
                let button = Button {
                    scanner.toggleScan()
                } label: {
                    if isScanningAvailable {
                        if true {
                            if isScanning {
                                Image(systemName: "antenna.radiowaves.left.and.right")
                                    .foregroundColor(.blue)
                                    .accessibilityLabel("stop scan")
                            }
                            else {
                                Image(systemName: "antenna.radiowaves.left.and.right.slash")
                                    .accessibilityLabel("start scan")
                            }
                        }
                        else {
                            Image(systemName: "antenna.radiowaves.left.and.right")
                                .foregroundColor(isScanning ? .blue : .secondary)
                                .accessibilityLabel(isScanning ? "stop scan" : "start scan")
                        }
                    }
                    else {
                        Image(systemName: "antenna.radiowaves.left.and.right.slash")
                            .accessibilityLabel("scanning not available")
                    }
                }
                .disabled(!isScanningAvailable)
                #if os(watchOS)
                    ToolbarItem(placement: .topBarTrailing) {
                        button
                    }
                #else
                    ToolbarItem(placement: .primaryAction) {
                        button
                    }
                #endif
            }
        }
        .onReceive(scanner.isScanningAvailablePublisher) { newIsScanningAvailable in
            isScanningAvailable = newIsScanningAvailable
        }.onReceive(scanner.isScanningPublisher) { newIsScanning in
            isScanning = newIsScanning
        }.onReceive(scanner.discoveredDevicesPublisher) { newDiscoveredDevices in
            discoveredDevices = newDiscoveredDevices
        }
    }
}

#Preview {
    Scanner()
        .environmentObject(NavigationManager())
    #if os(macOS)
        .frame(maxWidth: 350, minHeight: 300)
    #endif
}
