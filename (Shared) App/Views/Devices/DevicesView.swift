//
//  DevicesView.swift
//  BrilliantSoleSwiftDemo
//
//  Created by Zack Qattan on 2/13/25.
//

import BrilliantSole
import OSLog
import SwiftUI
import UkatonMacros

@StaticLogger
struct DevicesView: View {
    @EnvironmentObject var navigationManager: NavigationManager

    @State private var devices: [BSDevice] = .init()

    var body: some View {
        NavigationStack(path: $navigationManager.path) {
            List {
                if devices.isEmpty {
                    if devices.isEmpty {
                        HStack {
                            Spacer()
                            Text("no devices available")
                            Spacer()
                        }
                    }
                }
                else {
                    ForEach(devices) { device in
                        DeviceRow(device: device, includeConnectionType: true)
                            .id(device.id)
                    }
                }
            }
            .navigationTitle("Devices")
            .navigationDestination(for: BSDevice.self) { device in
                DeviceView(device: device)
            }
        }
        .onReceive(BSDeviceManager.availableDevicesPublisher) { devices in
            self.devices = devices
        }
        .onOpenURL { incomingURL in
            logger?.debug("(DeviceDiscovery) App was opened via URL: \(incomingURL)")
            handleIncomingURL(incomingURL)
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
            if let connectionId = components.queryItems?.first(where: { $0.name == "id" })?.value {
                guard let device = devices.first(where: { $0.connectionId == connectionId }) else {
                    logger?.error("no device found for connectionId \(connectionId)")
                    return
                }
                navigationManager.navigateTo(device)
            }
            else {
                logger?.error("no id query found in url")
            }
        default:
            logger?.error("uncaught action \"\(action)\"")
        }
    }
}

#Preview {
    DevicesView()
        .environmentObject(NavigationManager())
    #if os(macOS)
        .frame(maxWidth: 350, minHeight: 300)
    #endif
}
