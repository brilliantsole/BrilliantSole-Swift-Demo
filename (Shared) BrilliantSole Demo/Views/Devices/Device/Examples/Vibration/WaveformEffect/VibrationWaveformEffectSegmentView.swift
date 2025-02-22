//
//  VibrationWaveformEffectSegmentView.swift
//  BrilliantSoleSwiftDemo
//
//  Created by Zack Qattan on 2/22/25.
//

import BrilliantSole
import SwiftUI

struct VibrationWaveformEffectSegmentView: View {
    @Binding var segment: BSVibrationWaveformEffectSegment
    let vibratable: BSVibratable

    private var minDelayTextWidth: CGFloat {
        if isMacOs {
            80
        }
        else if is_iOS {
            100
        }
        else {
            100
        }
    }

    var body: some View {
        Button(action: {
            vibratable.triggerVibration(.init(locations: .all, waveformEffectSegments: [segment]))
        }) {
            Label("Trigger Segment", systemImage: "waveform.path")
        }

        Picker("__Type__", selection: $segment.segmentType) {
            ForEach(BSVibrationWaveformEffectSegmentType.allCases) { segmentType in
                Text(segmentType.name)
            }
        }

        switch segment.segmentType {
        case .effect:
            Picker("__Effect__", selection: $segment.effect) {
                ForEach(BSVibrationWaveformEffect.allCases) { waveformEffect in
                    Text(waveformEffect.name)
                        .tag(waveformEffect)
                }
            }
        case .delay:
            #if os(tvOS) || os(watchOS)
            Picker("__Delay__", selection: $segment.delay) {
                ForEach(Array(stride(from: 0, through: segment.maxDelay, by: .init(segment.delayStep))), id: \.self) { delay in
                    Text("\(delay)ms")
                        .tag(BSVibrationWaveformEffectDelay(delay))
                }
            }
            #else
            HStack {
                Text(String(format: "Delay %.2fs", Double(segment.delay) / 1000))
                    .bold()
                    .frame(minWidth: minDelayTextWidth)
                Slider(
                    value: Binding(
                        get: { Double(segment.delay) },
                        set: { segment.delay = .init($0) }
                    ),
                    in: 0 ... .init(segment.maxDelay),
                    step: .init(segment.delayStep)
                )
            }
            #endif
        }

        Picker("__Loop Count__", selection: $segment.loopCount) {
            ForEach(0 ... segment.maxLoopCount, id: \.self) { number in
                Text("\(number)").tag(number)
            }
        }
    }
}

#Preview {
    @Previewable @State var configuration: BSVibrationConfiguration = .init(locations: .all, waveformEffectSegments: [.init(effect: .none)])

    NavigationStack {
        List {
            Section {
                VibrationWaveformEffectSegmentView(segment: $configuration.waveformEffectSegments[0], vibratable: BSDevice.mock)
            } header: {
                Text("Segment #1")
            }
        }
    }
    #if os(macOS)
    .frame(maxWidth: 300, maxHeight: 300)
    #endif
}
