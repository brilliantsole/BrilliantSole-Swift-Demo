//
//  SensorRatePicker.swift
//  BrilliantSoleSwiftDemo
//
//  Created by Zack Qattan on 2/25/25.
//

import BrilliantSole
import Combine
import SwiftUI

struct SensorRatePicker: View {
    let device: BSDevice
    let sensorType: BSSensorType

    @State private var selectedSensorRate: BSSensorRate = ._0ms
    @State private var currentSensorRate: BSSensorRate = ._0ms

    init(device: BSDevice, sensorType: BSSensorType) {
        self.device = device
        self.sensorType = sensorType
        let currentSensorRate: BSSensorRate = device.sensorConfiguration[sensorType] ?? ._0ms
        self._selectedSensorRate = .init(initialValue: currentSensorRate)
        self._currentSensorRate = .init(initialValue: currentSensorRate)
    }

    var body: some View {
        Picker("__Sensor Rate (\(currentSensorRate.name))__ ", selection: $selectedSensorRate) {
            ForEach(BSSensorRate.allCases) { sensorRate in
                Text(sensorRate.name)
            }
        }
        .onChange(of: selectedSensorRate) { _, selectedSensorRate in
            if selectedSensorRate != currentSensorRate {
                device.setSensorRate(sensorType: sensorType, sensorRate: selectedSensorRate)
            }
        }
        .onReceive(device.sensorConfigurationPublisher.dropFirst()) { configuration in
            let newRate = configuration[sensorType] ?? ._0ms
            if newRate != currentSensorRate {
                currentSensorRate = newRate
            }
        }
    }
}

#Preview {
    List {
        SensorRatePicker(device: .mock, sensorType: .linearAcceleration)
    }
    #if os(macOS)
    .frame(maxWidth: 350, minHeight: 300)
    #endif
}
