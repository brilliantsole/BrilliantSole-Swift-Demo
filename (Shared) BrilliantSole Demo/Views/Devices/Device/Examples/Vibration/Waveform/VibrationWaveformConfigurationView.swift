//
//  VibrationWaveformConfigurationView.swift
//  BrilliantSoleSwiftDemo
//
//  Created by Zack Qattan on 2/21/25.
//

import BrilliantSole
import SwiftUI

struct VibrationWaveformConfigurationView: View {
    @Binding var configuration: BSVibrationConfiguration
    let vibratable: BSVibratable

    var body: some View {
        Button(action: {
            configuration.waveformSegments.append(.init(amplitude: 0.5, duration: 200))
        }) {
            Label("Add Segment (max \(configuration.waveformSegments.maxLength))", systemImage: "plus")
        }
        .disabled(configuration.waveformSegments.count >= configuration.waveformSegments.maxLength)

        ForEach(0 ..< configuration.waveformSegments.count, id: \.self) { index in
            Section {
                VibrationWaveformSegmentView(segment: $configuration.waveformSegments[index], vibratable: vibratable)
            } header: {
                HStack {
                    Text("Segment #\(index + 1) \(index == configuration.waveformSegments.maxLength - 1 ? "(max)" : "")")
                        .bold()
                    Spacer()
                    Button(role: .destructive, action: {
                        configuration.waveformSegments.remove(at: index)
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
}

#Preview {
    @Previewable @State var configuration: BSVibrationConfiguration = .init(locations: .all, waveformEffectSegments: .init())

    NavigationStack {
        List {
            VibrationWaveformConfigurationView(configuration: $configuration, vibratable: BSDevice.mock)
        }
    }
    #if os(macOS)
    .frame(maxWidth: 300, maxHeight: 300)
    #endif
}
