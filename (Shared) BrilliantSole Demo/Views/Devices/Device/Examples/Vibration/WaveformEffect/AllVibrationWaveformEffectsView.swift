//
//  AllVibrationWaveformEffectsView.swift
//  BrilliantSoleSwiftDemo
//
//  Created by Zack Qattan on 2/22/25.
//

import BrilliantSole
import SwiftUI

struct AllVibrationWaveformEffectsView: View {
    let vibratable: BSVibratable
    @State private var configuration: BSVibrationConfiguration = .init(locations: .all, waveformEffectSegments: [.init(effect: .none)])
    var body: some View {
        List {
            ForEach(BSVibrationWaveformEffect.allCases) { waveformEffect in
                Button(action: {
                    configuration.waveformEffectSegments[0].effect = waveformEffect
                    vibratable.triggerVibration(configuration)
                }, label: {
                    Text(waveformEffect.name)
                })
            }
        }
        .navigationTitle("All Waveform Effects")
    }
}

#Preview {
    NavigationStack {
        AllVibrationWaveformEffectsView(vibratable: BSDevice.mock)
    }
    #if os(macOS)
    .frame(maxWidth: 300, maxHeight: 300)
    #endif
}
