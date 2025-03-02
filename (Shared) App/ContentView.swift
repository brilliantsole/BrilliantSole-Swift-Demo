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

    @StateObject private var deviceNavigationManager = NavigationManager()
    @StateObject private var devicePairNavigationManager = NavigationManager()

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
                .environmentObject(deviceNavigationManager)
            #if !os(watchOS) && !os(tvOS)
                .badge(discoveredDeviceCount)
                .onReceive(scanner.discoveredDevicesPublisher) { discoveredDevices in
                    discoveredDeviceCount = discoveredDevices.count
                }
            #endif

            DevicesView()
                .modify {
                    if !isWatch {
                        $0.tabItem {
                            Label("Devices", systemImage: "shoe")
                        }
                    }
                }
                .tag(TabEnum.devices)
                .environmentObject(deviceNavigationManager)
            #if !os(watchOS) && !os(tvOS)
                .badge(deviceCount)
                .onReceive(BSDeviceManager.availableDevicesPublisher) { devices in
                    deviceCount = devices.count
                }
            #endif

            DevicePairView()
                .modify {
                    if !isWatch {
                        $0.tabItem { 
                            Label("Device Pair", systemImage: devicePairImageString)
                        }
                    }
                }
                .tag(TabEnum.devicePair)
                .environmentObject(devicePairNavigationManager)
        }.onReceive(devicePair.connectionStatusPublisher, perform: {
            devicePairConnectionStatus = $0
        })
        .environmentObject(vibrationConfigurationState)
        .environmentObject(tfliteFileState)
        .onOpenURL { incomingURL in
            logger?.debug("(ContentView) App was opened via URL: \(incomingURL)")
            handleIncomingURL(incomingURL)
        }
        .modify {
            #if os(macOS)
                $0.onReceive(NotificationCenter.default.publisher(for: NSWindow.willCloseNotification)) { _ in
                    // DeviceMetadataManager.shared.clear()
                }
            #endif
        }
    }

    private func handleIncomingURL(_ url: URL) {
        guard url.isDeeplink else {
            return
        }

        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: true),
              let action = components.host
        else {
            logger?.debug("Invalid URL")
            return
        }

        switch action {
        case "select-device":
            selectedTab = .devices
        default:
            logger?.debug("uncaught action \"\(action)\"")
        }
    }
}

#Preview {
    ContentView()
    #if os(macOS)
        .frame(maxWidth: 500, minHeight: 300)
    #endif
}
