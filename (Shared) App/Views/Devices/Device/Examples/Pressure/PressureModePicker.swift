//
//  PressureModePicker.swift
//  BrilliantSoleSwiftDemo
//
//  Created by Zack Qattan on 2/18/25.
//

import BrilliantSole
import SwiftUI
import UkatonMacros

struct PressureModePicker: View {
    let sensorConfigurable: BSSensorConfigurable

    @State private var isEnabled: Bool = false

    var body: some View {
        Button("\(isEnabled ? "disable" : "enable") pressure") {
            var sensorConfiguration: BSSensorConfiguration = .init()
            isEnabled.toggle()
            sensorConfiguration[.pressure] = isEnabled ? ._20ms : ._0ms
            sensorConfigurable.setSensorConfiguration(sensorConfiguration)
        }
    }
}

#Preview {
    NavigationStack {
        PressureModePicker(sensorConfigurable: BSDevice.mock)
    }
    #if os(macOS)
    .frame(maxWidth: 300)
    #endif
}
