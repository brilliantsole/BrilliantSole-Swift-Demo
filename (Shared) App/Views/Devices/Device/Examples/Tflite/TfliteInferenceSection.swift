//
//  TfliteInferenceSection.swift
//  BrilliantSoleSwiftDemo
//
//  Created by Zack Qattan on 2/24/25.
//

import BrilliantSole
import Combine
import SwiftUI

struct TfliteInferenceSection: View {
    let device: BSDevice
    @State private var inference: BSTfliteInference?

    init(device: BSDevice, inference: BSTfliteInference? = nil) {
        self.device = device
        self._inference = .init(initialValue: inference)
    }

    var formattedTimestamp: String {
        let date = Date(timeIntervalSince1970: TimeInterval(inference!.timestamp) / 1000.0)
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss.SSS"
        return formatter.string(from: date)
    }

    var body: some View {
        Group {
            if let inference {
                Section {
                    Text("__Timestamp__: \(formattedTimestamp)")
                    if let valueMap = inference.valueMap {
                        ForEach(valueMap.sorted(by: { $0.value > $1.value }), id: \.key) { key, value in
                            Text("__\(key):__ \(value)")
                        }
                    } else {
                        ForEach(Array(inference.values.enumerated()), id: \.offset) { index, value in
                            Text("__#\(index + 1):__ \(value)")
                        }
                    }
                } header: {
                    Text("Inference")
                }
            }
        }
        .onReceive(device.tfliteInferencePublisher) { inference = $0 }
    }
}

#Preview {
    @Previewable @State var inference: BSTfliteInference = (
        values: [0.359608, 0.029498, 0.118994, 0.491900],
        valueMap: ["idle": 0.359608, "kick": 0.029498, "stomp": 0.118994, "tap": 0.491900],
        timestamp: 0
    )
    List {
        TfliteInferenceSection(device: .mock, inference: inference)
    }
    #if os(macOS)
    .frame(maxWidth: 350, minHeight: 300)
    #endif
}
