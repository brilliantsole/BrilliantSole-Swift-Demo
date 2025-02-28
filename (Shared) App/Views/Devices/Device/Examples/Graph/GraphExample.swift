//
//  GraphExample.swift
//  BrilliantSoleSwiftDemo
//
//  Created by Zack Qattan on 2/22/25.
//

import BrilliantSole
import SwiftUI

struct GraphExample: View {
    let device: BSDevice

    @State private var maxDataPoints: Int = isWatch ? 40 : 100

    var body: some View {
        List {
            ForEach(BSSensorType.allCases.filter { device.containsSensorType($0) && $0.isContinuous }, id: \.rawValue) { sensorType in
                Graph(device: device, sensorType: sensorType, maxDataPoints: $maxDataPoints)
            }
        }
        .navigationTitle("Graph")
        .onDisappear {
            device.clearSensorConfiguration()
        }
    }
}

#Preview {
    NavigationStack {
        GraphExample(device: .mock)
    }
    #if os(macOS)
    .frame(maxWidth: 350, minHeight: 300)
    #endif
}
