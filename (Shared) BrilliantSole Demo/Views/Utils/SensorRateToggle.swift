//
//  SensorRateToggle.swift
//  BrilliantSoleSwiftDemo
//
//  Created by Zack Qattan on 2/25/25.
//

import BrilliantSole
import Combine
import SwiftUI

struct SensorRateToggle: View {
    let device: BSDevice
    let sensorType: BSSensorType
    let sensorRate: BSSensorRate

    @State private var selectedSensorRate: BSSensorRate = ._0ms
    @State private var currentSensorRate: BSSensorRate = ._0ms

    private var isEnabled: Bool { selectedSensorRate != ._0ms }

    init(device: BSDevice, sensorType: BSSensorType, sensorRate: BSSensorRate) {
        self.device = device
        self.sensorType = sensorType
        let currentSensorRate: BSSensorRate = device.sensorConfiguration[sensorType] ?? ._0ms
        self._selectedSensorRate = .init(initialValue: currentSensorRate)
        self._currentSensorRate = .init(initialValue: currentSensorRate)
        self.sensorRate = sensorRate
    }

    var body: some View {
        Button(isEnabled ? "disable" : "enable") {
            selectedSensorRate = isEnabled ? ._0ms : sensorRate
        }
        .onChange(of: selectedSensorRate) { _, selectedSensorRate in
            print("changing sensor rate \(sensorType.name) to \(selectedSensorRate.name)")
            if selectedSensorRate != currentSensorRate {
                device.setSensorRate(sensorType: sensorType, sensorRate: selectedSensorRate)
            }
        }
        .onReceive(device.sensorConfigurationPublisher.dropFirst()) { configuration in
            currentSensorRate = configuration[sensorType] ?? ._0ms
        }
    }
}

#Preview {
    List {
        SensorRateToggle(device: .mock, sensorType: .linearAcceleration, sensorRate: ._20ms)
    }
    #if os(macOS)
    .frame(maxWidth: 350, minHeight: 300)
    #endif
}
