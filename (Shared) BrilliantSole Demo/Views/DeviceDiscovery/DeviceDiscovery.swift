//
//  DeviceDiscovery.swift
//  BrilliantSoleSwiftDemo
//
//  Created by Zack Qattan on 2/10/25.
//

import BrilliantSole
import SwiftUI

struct DeviceDiscovery: View {
    @EnvironmentObject var navigationManager: NavigationManager

    @State private var selectedScannerType: BSConnectionType = .ble {
        didSet {
            oldValue.scanner.stopScan()
        }
    }

    private var scanner: BSScanner { selectedScannerType.scanner }
    @State private var isScanning: Bool = false
    @State private var isScanningAvailable: Bool = false

    var body: some View {
        NavigationStack(path: $navigationManager.path) {
            List {
                if !isWatch {
                    Picker("scanner type", selection: $selectedScannerType) {
                        ForEach(BSConnectionType.allCases) { connectionType in
                            Text(connectionType.name).tag(connectionType)
                        }
                    }
                }
            }
            .navigationTitle("Device Discovery")
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
            .onReceive(scanner.isScanningAvailablePublisher) { newIsScanningAvailable in
                print("newIsScanningAvailable \(newIsScanningAvailable)")
                isScanningAvailable = newIsScanningAvailable
            }.onReceive(scanner.isScanningPublisher) { newIsScanning in
                print("newIsScanning \(newIsScanning)")
                isScanning = newIsScanning
            }.onReceive(scanner.discoveredDevicePublisher) { discoveredDevice in
                // FILL
                print("new discoveredDevice \(discoveredDevice.name)")
            }
        }
    }
}

#Preview {
    DeviceDiscovery()
        .environmentObject(NavigationManager())
    #if os(macOS)
        .frame(maxWidth: 350, minHeight: 300)

    #endif
}
