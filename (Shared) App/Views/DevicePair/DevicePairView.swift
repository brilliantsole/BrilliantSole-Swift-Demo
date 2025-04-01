//
//  DevicePairView.swift
//  BrilliantSoleSwiftDemo
//
//  Created by Zack Qattan on 2/10/25.
//

import BrilliantSole
import Combine
import SwiftUI

struct DevicePairView: View {
    let devicePair: BSDevicePair = .insoles
    @State var connectionStatus: BSDevicePairConnectionStatus = .notConnected

    @EnvironmentObject var navigationManager: NavigationManager

    var notConnectedMessage: String {
        return switch connectionStatus {
        case .notConnected:
            "connect a left and right insole"
        case .halfConnected:
            "connect a \(devicePair.unconnectedSide!.name) insole"
        case .fullyConnected:
            "you shouldn't see this"
        }
    }

    var body: some View {
        NavigationStack(path: $navigationManager.path) {
            List {
                if devicePair.isFullyConnected {
                    DevicePairExamplesSection(devicePair: devicePair)
                }
                else {
                    HStack {
                        Spacer()
                        Text(notConnectedMessage)
                        Spacer()
                    }
                }
            }
            .navigationDestination(for: DevicePairExample.self) { example in
                example.view(devicePair: devicePair)
            }
        }
        .onReceive(devicePair.connectionStatusPublisher) { connectionStatus = $0 }
        .navigationTitle("Device Pair")

        .onReceive(devicePair.isFullyConnectedPublisher) { isFullyConnected in
            if !isFullyConnected, !navigationManager.path.isEmpty {
                print("resetting navigation")
                navigationManager.resetNavigation()
            }
        }
    }
}

#Preview {
    @Previewable @StateObject var navigationManager = NavigationManager()
    @Previewable @StateObject var vibrationConfigurationsState = VibrationConfigurationsState()

    DevicePairView()
        .environmentObject(navigationManager)
        .environmentObject(vibrationConfigurationsState)
    #if os(macOS)
        .frame(maxWidth: 350, maxHeight: 300)
    #endif
}
