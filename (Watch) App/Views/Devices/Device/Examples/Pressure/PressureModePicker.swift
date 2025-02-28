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

    private var systemImage: String {
        if sensorConfigurable.isDevicePair {
            return isEnabled ? "shoe.2.fill" : "shoe.2"
        }
        else {
            return isEnabled ? "shoe.fill" : "shoe"
        }
    }

    var body: some View {
        VStack {}
            .toolbar {
                ToolbarItem(placement: .bottomBar) {
                    Button {
                        var sensorConfiguration: BSSensorConfiguration = .init()
                        isEnabled.toggle()
                        sensorConfiguration[.pressure] = isEnabled ? ._20ms : ._0ms
                        sensorConfigurable.setSensorConfiguration(sensorConfiguration)
                    } label: {
                        Image(systemName: systemImage)
                    }
                    .foregroundColor(isEnabled ? .green : .primary)
                    .accessibilityLabel(isEnabled ? "disable rotation" : "enable rotation")
                }
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
