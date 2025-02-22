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

    var body: some View {
        Picker("loop count", selection: $configuration.loopCount) {
            ForEach(0 ... BSVibrationWaveformEffectSegments.maxWaveformEffectSegmentsLoopCount, id: \.self) { number in
                Text("\(number)").tag(number)
            }
        }
    }
}

#Preview {
    @Previewable @State var configuration: BSVibrationConfiguration = .init(locations: .all, waveformEffectSegments: .init())

    NavigationStack {
        List {
            VibrationWaveformEffectConfigurationView(configuration: $configuration)
        }
    }
    #if os(macOS)
    .frame(maxWidth: 300, maxHeight: 300)
    #endif
}
