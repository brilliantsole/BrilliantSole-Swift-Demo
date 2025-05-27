//
//  VibrationExample.swift
//  BrilliantSoleSwiftDemo
//
//  Created by Zack Qattan on 2/21/25.
//

import BrilliantSole
import Combine
import SwiftUI

struct VibrationExample: View {
    let vibratable: BSVibratable

    @EnvironmentObject var configurationsState: VibrationConfigurationsState
    private var configurations: BSVibrationConfigurations { configurationsState.configurations }

    var body: some View {
        let layout = isWatch ? AnyLayout(VStackLayout()) : AnyLayout(HStackLayout())

        List {
            Section {
                NavigationLink("Explore Waveform Effects...") {
                    AllVibrationWaveformEffectsView(vibratable: vibratable)
                }
            }

            Button(action: {
                configurationsState.configurations.append(.init(locations: vibratable.vibrationLocations, waveformEffectSegments: .init()))
            }) {
                Label("Waveform Effect", systemImage: "plus")
            }
            Button(action: {
                configurationsState.configurations.append(.init(locations: vibratable.vibrationLocations, waveformSegments: .init()))
            }) {
                Label("Waveform", systemImage: "plus")
            }

            Section {
                if !configurations.isEmpty {
                    Button(action: {
                        vibratable.triggerVibration(configurations)
                    }) {
                        Label("Trigger Configurations", systemImage: "waveform.path")
                    }
                    .disabled(configurations.allSatisfy(\.segments.isEmpty))
                }
            }

            ForEach(0 ..< configurations.count, id: \.self) { index in
                Section {
                    VibrationConfigurationView(configuration: $configurationsState.configurations[index], vibratable: vibratable)
                } header: {
                    layout {
                        Text("#\(index + 1) \(configurations[index].type.name)")
                            .bold()
                        Spacer()
                        Button(role: .destructive, action: {
                            configurationsState.configurations.remove(at: index)
                        }) {
                            Text("Remove")
                        }
                        #if os(macOS) || os(watchOS)
                        .tint(.red)
                        .buttonStyle(.borderedProminent)
                        #endif
                    }
                }
            }
        }
        .navigationTitle("Vibration")
    }
}

#Preview {
    @Previewable @StateObject var vibrationConfigurationState = VibrationConfigurationsState()

    NavigationStack {
        VibrationExample(vibratable: BSDevice.mock)
    }
    .environmentObject(vibrationConfigurationState)
    #if os(macOS)
        .frame(maxWidth: 350, minHeight: 300)
    #endif
}
