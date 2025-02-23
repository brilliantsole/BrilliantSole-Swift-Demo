//
//  ContentView.swift
//  BrilliantSoleSwiftDemo
//
//  Created by Zack Qattan on 1/15/25.
//

import BrilliantSole
import Combine
import OSLog
import SwiftUI
import UkatonMacros

@StaticLogger
struct ContentView: View {
    // MARK: - tabEum

    @EnumName
    enum TabEnum: Identifiable {
        var id: String { name }

        case scanner
        case devices
        case devicePair

        var requiresDevicePair: Bool {
            switch self {
            case .devicePair:
                true
            default:
                false
            }
        }
    }

    @State private var selectedTab: TabEnum = .scanner

    // MARK: - devicePair

    private let devicePair: BSDevicePair = .shared
    var devicePairImageString: String {
        switch devicePairConnectionStatus {
        case .notConnected:
            "circle.dashed"
        case .halfConnected:
            "shoe.fill"
        case .fullyConnected:
            "shoe.2.fill"
        }
    }

    @State private var devicePairConnectionStatus: BSDevicePairConnectionStatus = .notConnected

    // MARK: - navigation

    @StateObject private var navigationManager = NavigationManager()

    // MARK: - deviceCount

    @State private var discoveredDeviceCount: Int = 0
    @State private var deviceCount: Int = 0

    // MARK: - vibrationConfiguration

    @StateObject private var vibrationConfigurationState = VibrationConfigurationsState()

    // MARK: - tfliteFile

    @StateObject private var tfliteFileState = TfliteFileState()

    // MARK: - scannerType

    @State private var selectedScannerType: BSConnectionType = .ble
    private var scanner: BSScanner { selectedScannerType.scanner }

    // MARK: - body

    var body: some View {
        TabView(selection: $selectedTab) {
            Scanner(selectedScannerType: $selectedScannerType)
                .modify {
                    if !isWatch {
                        $0.tabItem {
                            Label("Scanner", systemImage: "antenna.radiowaves.left.and.right")
                        }
                    }
                }
                .tag(TabEnum.scanner)
            #if !os(watchOS)
                .badge(discoveredDeviceCount)
                .onReceive(scanner.discoveredDevicesPublisher) { discoveredDevices in
                    discoveredDeviceCount = discoveredDevices.count
                }
            #endif

            Devices()
                .modify {
                    if !isWatch {
                        $0.tabItem {
                            Label("Devices", systemImage: "shoe")
                        }
                    }
                }
                .tag(TabEnum.devices)
            #if !os(watchOS)
                .badge(deviceCount)
                .onReceive(BSDeviceManager.availableDevicesPublisher) { devices in
                    deviceCount = devices.count
                }
            #endif

            DevicePair()
                .modify {
                    if !isWatch {
                        $0.tabItem {
                            Label("Device Pair", systemImage: devicePairImageString)
                        }
                    }
                }
                .tag(TabEnum.devicePair)
        }.onReceive(devicePair.connectionStatusPublisher, perform: {
            devicePairConnectionStatus = $0
        })
        .environmentObject(navigationManager)
        .environmentObject(vibrationConfigurationState)
        .environmentObject(tfliteFileState)
    }
}

#Preview {
    ContentView()
    #if os(macOS)
        .frame(maxWidth: 410, minHeight: 300)
    #endif
}
