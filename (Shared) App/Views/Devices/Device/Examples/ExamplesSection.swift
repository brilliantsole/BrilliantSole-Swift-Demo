//
//  ExamplesSection.swift
//  BrilliantSoleSwiftDemo
//
//  Created by Zack Qattan on 2/18/25.
//

import BrilliantSole
import SwiftUI

struct ExamplesSection: View {
    let device: BSDevice

    @EnvironmentObject var navigationManager: NavigationManager

    var body: some View {
        Section {
            ForEach(Example.allCases) { example in
                if example.worksWith(device: device) {
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
            Text("Examples")
                .font(.headline)
        }
    }
}

#Preview {
    @Previewable @StateObject var navigationManager = NavigationManager()

    let device: BSDevice = .mock

    NavigationStack(path: $navigationManager.path) {
        List {
            ExamplesSection(device: device)
        }
        .navigationDestination(for: Example.self) { example in
            example.view(device: device)
        }
    }
    .environmentObject(navigationManager)
    #if os(macOS)
        .frame(maxWidth: 350, maxHeight: 300)
    #endif
}
