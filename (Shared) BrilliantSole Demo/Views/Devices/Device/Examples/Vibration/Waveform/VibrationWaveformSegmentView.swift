//
//  VibrationWaveformSegmentView.swift
//  BrilliantSoleSwiftDemo
//
//  Created by Zack Qattan on 2/22/25.
//

import BrilliantSole
import SwiftUI

struct VibrationWaveformSegmentView: View {
    @Binding var segment: BSVibrationWaveformSegment
    let vibratable: BSVibratable

    private var minAmplitudeTextWidth: CGFloat {
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

    private var minDurationTextWidth: CGFloat {
        if isMacOs {
            100
        }
        else if is_iOS {
            120
        }
        else {
            120
        }
    }

    var body: some View {
        Button(action: {
            vibratable.triggerVibration(.init(locations: .all, waveformSegments: [segment]))
        }) {
            Label("Trigger Segment", systemImage: "waveform.path")
        }

        #if os(tvOS) || os(watchOS)
        Picker("__Amplitude__", selection: $segment.amplitude) {
            ForEach(Array(stride(from: 0.0, through: 1.0, by: .init(segment.amplitudeStep * 16)) + [1.0]), id: \.self) { amplitude in
                Text("\(Int(amplitude * 100))%")
                    .tag(Float(amplitude))
            }
        }
        #else
        HStack {
            Text("Amplitude")
                .bold()
                .frame(minWidth: minAmplitudeTextWidth, alignment: .leading)
            Slider(
                value: $segment.amplitude
            )
        }
        #endif

        #if os(tvOS) || os(watchOS)
        Picker("__Duration__", selection: $segment.duration) {
            ForEach(Array(stride(from: 0, through: segment.maxDuration, by: .init(segment.durationStep * 20)) + [segment.maxDuration]), id: \.self) { duration in
                Text("\(duration)ms")
                    .tag(BSVibrationWaveformSegmentDuration(duration))
            }
        }
        #else
        HStack {
            Text(String(format: "Duration %.2fs", Double(segment.duration) / 1000))
                .bold()
                .frame(minWidth: minDurationTextWidth, alignment: .leading)
            Slider(
                value: Binding(
                    get: { Double(segment.duration) },
                    set: { segment.duration = .init($0) }
                ),
                in: 0 ... .init(segment.maxDuration),
                step: .init(segment.durationStep * 20)
            )
        }
        #endif
    }
}

#Preview {
    @Previewable @State var configuration: BSVibrationConfiguration = .init(locations: .all, waveformSegments: [.init(amplitude: 0.5, duration: 200)])

    NavigationStack {
        List {
            Section {
                VibrationWaveformSegmentView(segment: $configuration.waveformSegments[0], vibratable: BSDevice.mock)
            } header: {
                Text("Segment #1")
            }
        }
    }
    #if os(macOS)
    .frame(maxWidth: 300, maxHeight: 300)
    #endif
}
