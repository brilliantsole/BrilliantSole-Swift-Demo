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
    let centerOfPressureProvider: BSCenterOfPressureProvider

    var body: some View {
        VStack(spacing: 0) {
            CenterOfPressureView(centerOfPressureProvider: centerOfPressureProvider)
            PressureModePicker(sensorConfigurable: centerOfPressureProvider)
        }
        .navigationTitle("Center of Pressure")
        .onDisappear {
            centerOfPressureProvider.clearSensorConfiguration()
        }
    }
}

#Preview {
    NavigationStack {
        CenterOfPressureExample(centerOfPressureProvider: BSDevice.mock)
    }
    #if os(macOS)
    .frame(maxWidth: 350, minHeight: 300)
    #endif
}
