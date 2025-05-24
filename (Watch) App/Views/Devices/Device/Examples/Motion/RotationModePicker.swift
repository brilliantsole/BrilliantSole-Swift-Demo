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
    let sensorConfigurable: BSSensorConfigurable

    @State private var isEnabled: Bool = false

    let sensorTypes: [BSSensorType] = [.gameRotation, .rotation, .orientation]
    var sensorType: BSSensorType? {
        sensorTypes.first { sensorConfigurable.sensorTypes.contains($0) }
    }

    var body: some View {
        VStack {}
            .toolbar {
                ToolbarItem(placement: .bottomBar) {
                    Button {
                        guard let sensorType else {
                            return
                        }
                        var sensorConfiguration: BSSensorConfiguration = .init()
                        isEnabled.toggle()
                        sensorConfiguration[sensorType] = isEnabled ? ._20ms : ._0ms
                        sensorConfigurable.setSensorConfiguration(sensorConfiguration)
                    } label: {
                        Image(systemName: isEnabled ? "rotate.3d.fill" : "rotate.3d")
                    }
                    .foregroundColor(isEnabled ? .green : .primary)
                    .accessibilityLabel(isEnabled ? "disable pressure" : "enable pressure")
                }
            }
    }
}

#Preview {
    NavigationStack {
        RotationModePicker(sensorConfigurable: BSDevice.mock)
    }
}
