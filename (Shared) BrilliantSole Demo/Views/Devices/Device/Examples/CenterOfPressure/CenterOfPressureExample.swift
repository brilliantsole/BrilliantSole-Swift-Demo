//
//  CenterOfPressureExample.swift
//  BrilliantSoleSwiftDemo
//
//  Created by Zack Qattan on 2/21/25.
//

import BrilliantSole
import Combine
import SwiftUI

struct CenterOfPressureExample: View {
    let device: BSDevice

    var body: some View {
        VStack(spacing: 0) {
            CenterOfPressureView(centerOfPressureProvider: device)
            PressureModePicker(sensorConfigurable: device)
        }
        .navigationTitle("Center of Pressure")
        .onDisappear {
            device.clearSensorConfiguration()
        }
    }
}

#Preview {
    CenterOfPressureExample(device: .mock)
    #if os(macOS)
        .frame(maxWidth: 350, minHeight: 300)
    #endif
}
