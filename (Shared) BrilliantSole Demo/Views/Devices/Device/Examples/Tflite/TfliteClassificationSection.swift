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
    @State private var classification: BSTfliteClassification?

    init(device: BSDevice, classification: BSTfliteClassification? = nil) {
        self.device = device
        self._classification = .init(initialValue: classification)
    }

    var formattedTimestamp: String {
        let date = Date(timeIntervalSince1970: TimeInterval(classification!.timestamp) / 1000.0)
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss.SSS"
        return formatter.string(from: date)
    }

    var body: some View {
        Group {
            if let classification {
                Section {
                    Text("__Timestamp__: \(formattedTimestamp)")
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
    @Previewable @State var classification: BSTfliteClassification? = (
        name: "Stomp",
        value: 1.0,
        timestamp: 1700000000123
    )

    List {
        TfliteClassificationSection(device: .mock, classification: classification)
    }
    #if os(macOS)
    .frame(maxWidth: 350, minHeight: 300)
    #endif
}
