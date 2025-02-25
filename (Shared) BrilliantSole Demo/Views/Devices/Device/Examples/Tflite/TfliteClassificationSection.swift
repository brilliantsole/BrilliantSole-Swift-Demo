//
//  TfliteClassificationSection.swift
//  BrilliantSoleSwiftDemo
//
//  Created by Zack Qattan on 2/24/25.
//

import BrilliantSole
import Combine
import SwiftUI

struct TfliteClassificationSection: View {
    let device: BSDevice

    @State private var classification: BSTfliteClassification? = (
        name: "Stomp",
        value: 1.0,
        timestamp: 0
    )

    var body: some View {
        Group {
            if let classification {
                Section {
                    Text("__Timestamp__: \(classification.timestamp)")
                    Text("__Classification__: \(classification.name)")
                    Text("__Value__: \(classification.value)")
                } header: {
                    Text("Classification")
                }
            }
        }
        .onReceive(device.tfliteClassificationPublisher) { classification = $0 }
    }
}

#Preview {
    List {
        TfliteClassificationSection(device: .mock)
    }
    #if os(macOS)
    .frame(maxWidth: 350, minHeight: 300)
    #endif
}
