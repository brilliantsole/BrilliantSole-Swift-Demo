//
//  VibrationConfigurationView.swift
//  BrilliantSoleSwiftDemo
//
//  Created by Zack Qattan on 2/21/25.
//

import BrilliantSole
import SwiftUI

struct VibrationConfigurationView: View {
    @Binding var configuration: BSVibrationConfiguration
    let vibratable: BSVibratable

    var body: some View {
        Section {
            Button(action: {
                vibratable.triggerVibration(configuration)
            }) {
                Label("Trigger Configuration", systemImage: "waveform.path")
            }
            .disabled(configuration.segments.isEmpty)
        }

        Picker("__type__", selection: $configuration.type) {
            ForEach(BSVibrationType.allCases) { vibrationType in
                Text(vibrationType.name)
            }
        }

        Section {
            ForEach(BSVibrationLocationFlag.allCases) { location in
                Toggle(location.name, isOn: Binding(
                    get: { configuration.locations.contains(location) },
                    set: { newValue in
                        if newValue {
                            configuration.locations.append(location)
                        } else {
                            configuration.locations.removeAll(where: { $0 == location })
                        }
                    }
                ))
            }
        } header: {
            Text("Locations")
                .font(.headline)
        }

        switch configuration.type {
        case .waveformEffect:
            VibrationWaveformEffectConfigurationView(configuration: $configuration, vibratable: vibratable)
        case .waveform:
            VibrationWaveformConfigurationView(configuration: $configuration)
        }
    }
}

#Preview {
    @Previewable @State var configuration: BSVibrationConfiguration = .init(locations: .all, waveformSegments: .init())

    NavigationStack {
        List {
            VibrationConfigurationView(configuration: $configuration, vibratable: BSDevice.mock)
        }
    }
    #if os(macOS)
    .frame(maxWidth: 300, maxHeight: 300)
    #endif
}
