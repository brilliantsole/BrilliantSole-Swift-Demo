//
//  TfliteInferenceSettingsSection.swift
//  BrilliantSoleSwiftDemo
//
//  Created by Zack Qattan on 2/24/25.
//

import BrilliantSole
import Combine
import SwiftUI

struct TfliteInferenceSettingsSection: View {
    let device: BSDevice

    @State private var captureDelay: BSTfliteCaptureDelay = .zero
    @State private var threshold: BSTfliteThreshold = .zero

    private var minThresholdTextWidth: CGFloat {
        if isMacOs {
            90
        } else if is_iOS {
            100
        } else {
            100
        }
    }

    private var maxCaptureDelayTextWidth: CGFloat {
        if isMacOs {
            80
        } else if is_iOS {
            100
        } else {
            100
        }
    }

    var body: some View {
        Section {
            #if os(tvOS) || os(watchOS)
                Picker("__Threshold__", selection: $threshold) {
                    ForEach(Array(stride(from: 0.0, through: BSTfliteFile.MaxThreshold, by: 0.1)), id: \.self) { threshold in
                        Text(String(format: "%.1f", threshold))
                            .tag(BSTfliteThreshold(threshold))
                    }
                }
            #else
                HStack {
                    Text("Threshold \(String(format: "%.1f", threshold))")
                        .bold()
                        .frame(minWidth: minThresholdTextWidth, alignment: .leading)
                    Slider(
                        value: $threshold
                    )
                }
            #endif

            #if os(tvOS) || os(watchOS)
                Picker("__Capture Delay__", selection: $captureDelay) {
                    ForEach(Array(stride(from: 0, through: BSTfliteFile.MaxCaptureDelay, by: 200)), id: \.self) { captureDelay in
                        Text("\(captureDelay)ms")
                            .tag(BSTfliteCaptureDelay(captureDelay))
                    }
                }
            #else
                HStack {
                    Text(String(format: "Capture Delay %.2fs", Double(captureDelay) / 1000))
                        .bold()
                        .frame(maxWidth: maxCaptureDelayTextWidth, alignment: .leading)
                    Slider(
                        value: Binding(
                            get: { Double(captureDelay) },
                            set: { captureDelay = .init($0) }
                        ),
                        in: 0 ... .init(BSTfliteFile.MaxCaptureDelay),
                        step: 100
                    )
                }
            #endif
        } header: {
            Text("Inference Settings")
        }
    }
}

#Preview {
    List {
        TfliteInferenceSettingsSection(device: .mock)
    }
    #if os(macOS)
    .frame(maxWidth: 350, minHeight: 300)
    #endif
}
