//
//  DevicePairPressureExample.swift
//  BrilliantSoleSwiftDemo
//
//  Created by Zack Qattan on 2/27/25.
//

import BrilliantSole
import Combine
import SwiftUI

struct DevicePairPressureExample: View {
    let devicePair: BSDevicePair

    var body: some View {
        VStack {
            HStack {
                PressureView(device: devicePair[.left] ?? .mock)
                PressureView(device: devicePair[.right] ?? .mock)
            }
            PressureModePicker(sensorConfigurable: devicePair)
        }
        .navigationTitle("Pressure")
        .onDisappear {
            devicePair.clearSensorConfiguration()
        }
    }
}

#Preview {
    NavigationStack {
        DevicePairPressureExample(devicePair: .shared)
    }
    #if os(macOS)
    .frame(maxWidth: 350, minHeight: 300)
    #endif
}
