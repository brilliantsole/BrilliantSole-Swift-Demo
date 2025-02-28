//
//  TranslationModePicker.swift
//  BrilliantSoleSwiftDemo
//
//  Created by Zack Qattan on 2/18/25.
//

import BrilliantSole
import SwiftUI
import UkatonMacros

struct TranslationModePicker: View {
    let sensorConfigurable: BSSensorConfigurable

    @State private var isEnabled: Bool = false

    var body: some View {
        VStack {}
            .toolbar {
                ToolbarItem(placement: .bottomBar) {
                    Button {
                        var sensorConfiguration: BSSensorConfiguration = .init()
                        isEnabled.toggle()
                        sensorConfiguration[.linearAcceleration] = isEnabled ? ._20ms : ._0ms
                        sensorConfigurable.setSensorConfiguration(sensorConfiguration)
                    } label: {
                        Image(systemName: "move.3d")
                    }
                    .foregroundColor(isEnabled ? .green : .primary)
                    .accessibilityLabel(isEnabled ? "disable translation" : "enable translation")
                }
            }
    }
}

#Preview {
    NavigationStack {
        TranslationModePicker(sensorConfigurable: BSDevice.mock)
    }
}
