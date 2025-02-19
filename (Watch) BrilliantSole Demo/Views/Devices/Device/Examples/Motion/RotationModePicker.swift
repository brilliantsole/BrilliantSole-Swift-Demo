//
//  RotationModePicker.swift
//  BrilliantSoleSwiftDemo
//
//  Created by Zack Qattan on 2/18/25.
//

import BrilliantSole
import SwiftUI
import UkatonMacros

struct RotationModePicker: View {
    let sensorDataConfigurable: BSSensorConfigurable

    @State private var isEnabled: Bool = false

    var body: some View {
        Group {}
            .toolbar {
                ToolbarItem(placement: .bottomBar) {
                    Button {
                        var sensorConfiguration: BSSensorConfiguration = .init()
                        isEnabled.toggle()
                        sensorConfiguration[.rotation] = isEnabled ? ._20ms : ._0ms
                        sensorDataConfigurable.setSensorConfiguration(sensorConfiguration, clearRest: true)
                    } label: {
                        Image(systemName: isEnabled ? "rotate.3d.fill" : "rotate.3d")
                    }
                    .foregroundColor(isEnabled ? .green : .primary)
                    .accessibilityLabel(isEnabled ? "disable rotation" : "enable rotation")
                }
            }
    }
}

#Preview {
    NavigationStack {
        RotationModePicker(sensorDataConfigurable: BSDevice.mock)
    }
    #if os(macOS)
    .frame(maxWidth: 300)
    #endif
}
