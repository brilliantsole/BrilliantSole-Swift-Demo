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

    @Binding private var selectedScannerType: BSConnectionType

    private var scanner: BSScanner { selectedScannerType.scanner }
    @State private var isScanning: Bool = false
    @State private var isScanningAvailable: Bool = false

    @State private var discoveredDevices: [BSDiscoveredDevice] = .init()

    init(selectedScannerType: Binding<BSConnectionType>) {
        self._selectedScannerType = selectedScannerType
        _isScanning = .init(initialValue: scanner.isScanning)
        _isScanningAvailable = .init(initialValue: scanner.isScanningAvailable)
        _discoveredDevices = .init(initialValue: scanner.discoveredDevices)
        #if !os(visionOS) && !os(tvOS)
            DiscoveredDeviceMetadataManager.shared.listenForUpdates()
            DeviceMetadataManager.shared.listenForUpdates()
        #endif
    }

    var body: some View {
        NavigationStack(path: $navigationManager.path) {
            List {
                if !isWatch || isPreview {
                    VStack {
                        Picker("scanner type", selection: $selectedScannerType) {
                            ForEach(BSConnectionType.allCases) { connectionType in
                                Text(connectionType.name).tag(connectionType)
                            }
                        }
                    }
                    .onChange(of: selectedScannerType) { oldValue, _ in
                        oldValue.scanner.stopScan()
                    }

                    if selectedScannerType == .udpClient {
                        UdpClientView()
                    }
                }

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
                        DiscoveredDeviceRow(discoveredDevice: discoveredDevice) {
                            if isScanning {
                                scanner.stopScan()
                            }
                        }
                        .id(discoveredDevice.id)
                    }
                }
            }
            .navigationTitle("Scanner")
            .navigationDestination(for: BSDevice.self) { device in
                DeviceView(device: device)
            }
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
    @Previewable @State var selectedScannerType: BSConnectionType = .ble

    Scanner(selectedScannerType: $selectedScannerType)
        .environmentObject(NavigationManager())
    #if os(macOS)
        .frame(maxWidth: 350, minHeight: 300)
    #endif
}
