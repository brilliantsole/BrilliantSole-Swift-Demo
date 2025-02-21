//
//  PressureExample.swift
//  BrilliantSoleSwiftDemo
//
//  Created by Zack Qattan on 2/21/25.
//

import BrilliantSole
import Combine
import SwiftUI

struct PressureExample: View {
    let device: BSDevice

    var body: some View {
        VStack {
            PressureView(device: device)
            PressureModePicker(sensorConfigurable: device)
        }
        .navigationTitle("Pressure")
        .onDisappear {
            device.clearSensorConfiguration()
        }
    }
}

#Preview {
    PressureExample(device: .mock)
    #if os(macOS)
        .frame(maxWidth: 350, minHeight: 300)
    #endif
}
