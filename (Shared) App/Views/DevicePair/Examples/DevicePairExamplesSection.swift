//
//  DevicePairExamplesSection.swift
//  BrilliantSoleSwiftDemo
//
//  Created by Zack Qattan on 2/18/25.
//

import BrilliantSole
import SwiftUI

struct DevicePairExamplesSection: View {
    let devicePair: BSDevicePair

    @EnvironmentObject var navigationManager: NavigationManager

    var body: some View {
        Section {
            ForEach(DevicePairExample.allCases) { example in
                if example.worksWith(devicePair: devicePair) {
                    Button(action: {
                        navigationManager.navigateTo(example)
                    }) {
                        HStack {
                            Text(example.name)
                            Spacer()
                            Image(systemName: "chevron.right")
                        }
                    }
                    #if os(macOS)
                    .buttonStyle(.link)
                    #endif
                }
            }
        } header: {
            Text("Device Pair Examples")
                .font(.headline)
        }
    }
}

#Preview {
    @Previewable @StateObject var navigationManager = NavigationManager()

    let devicePair: BSDevicePair = .shared

    NavigationStack(path: $navigationManager.path) {
        List {
            DevicePairExamplesSection(devicePair: devicePair)
        }
        .navigationDestination(for: DevicePairExample.self) { example in
            example.view(devicePair: devicePair)
        }
    }
    .environmentObject(navigationManager)
    #if os(macOS)
        .frame(maxWidth: 350, maxHeight: 300)
    #endif
}
