//
//  TfliteInferencingSection.swift
//  BrilliantSoleSwiftDemo
//
//  Created by Zack Qattan on 2/24/25.
//

import BrilliantSole
import Combine
import SwiftUI

struct TfliteInferencingSection: View {
    let device: BSDevice

    @State private var isTfliteReady = false
    @State private var isTfliteInferencingEnabled = false

    var body: some View {
        Section {
            Text("__Is Ready?__ \(isTfliteReady ? "Yes" : "No")")
                .onReceive(device.isTfliteReadyPublisher) { isTfliteReady = $0 }

            if isTfliteReady {
                Button(isTfliteInferencingEnabled ? "disable model" : "enable model") {
                    device.toggleTfliteInferencingEnabled()
                }
                .onReceive(device.tfliteInferencingEnabledPublisher) { isTfliteInferencingEnabled = $0 }
            }
        } header: {
            Text("Inferencing")
        }
        .onReceive(device.tfliteInferencingEnabledPublisher) {
            isTfliteInferencingEnabled = $0
        }
        .onReceive(device.isTfliteReadyPublisher) {
            isTfliteReady = $0
        }
    }
}

#Preview {
    List {
        TfliteInferencingSection(device: .mock)
    }
    #if os(macOS)
    .frame(maxWidth: 350, minHeight: 300)
    #endif
}
