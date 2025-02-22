//
//  VibrationWaveformEffectConfigurationView.swift
//  BrilliantSoleSwiftDemo
//
//  Created by Zack Qattan on 2/21/25.
//

import BrilliantSole
import SwiftUI

struct VibrationWaveformEffectConfigurationView: View {
    @Binding var configuration: BSVibrationConfiguration
    let vibratable: BSVibratable

    var body: some View {
        Picker("__Loop Count__", selection: $configuration.loopCount) {
            ForEach(0 ... configuration.waveformEffectSegments.maxLoopCount, id: \.self) { number in
                Text("\(number)").tag(number)
            }
        }

        Button(action: {
            configuration.waveformEffectSegments.append(.init(effect: .none))
        }) {
            Label("Add Segment (max \(configuration.waveformEffectSegments.maxLength))", systemImage: "plus")
        }
        .disabled(configuration.waveformEffectSegments.count >= configuration.waveformEffectSegments.maxLength)

        ForEach(0 ..< configuration.waveformEffectSegments.count, id: \.self) { index in
            Section {
                VibrationWaveformEffectSegmentView(segment: $configuration.waveformEffectSegments[index], vibratable: vibratable)
            } header: {
                HStack {
                    Text("Segment #\(index + 1) \(index == configuration.waveformEffectSegments.maxLength - 1 ? "(max)" : "")")
                        .bold()
                    Spacer()
                    Button(role: .destructive, action: {
                        configuration.waveformEffectSegments.remove(at: index)
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
            VibrationWaveformEffectConfigurationView(configuration: $configuration, vibratable: BSDevice.mock)
        }
    }
    #if os(macOS)
    .frame(maxWidth: 300, maxHeight: 300)
    #endif
}
