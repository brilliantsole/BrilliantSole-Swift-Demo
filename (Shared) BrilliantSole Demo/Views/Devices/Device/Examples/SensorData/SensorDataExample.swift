//
//  SensorDataExample.swift
//  BrilliantSoleSwiftDemo
//
//  Created by Zack Qattan on 2/27/25.
//

import BrilliantSole
import Combine
import SwiftUI

struct SensorDataExample: View {
    let device: BSDevice

    var body: some View {
        List {
            if device.containsSensorType(.pressure) {
                PressureDataSection(device: device)
            }
            MotionDataSection(device: device)
            if device.containsSensorType(.barometer) {
                BarometerDataSection(device: device)
            }
        }
        .navigationTitle("Sensor Data")
        .onDisappear {
            device.clearSensorConfiguration()
        }
    }
}

#Preview {
    NavigationStack {
        SensorDataExample(device: .mock)
    }
    #if os(macOS)
    .frame(maxWidth: 350, minHeight: 300)
    #endif
}
