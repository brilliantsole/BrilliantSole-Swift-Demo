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

    @State private var isEditingCaptureDelay: Bool = false
    @State private var isEditingThreshold: Bool = false

    init(device: BSDevice) {
        self.device = device
        self._captureDelay = .init(initialValue: device.tfliteCaptureDelay)
        self._threshold = .init(initialValue: device.tfliteThreshold)
    }

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
                .onChange(of: $threshold) { _, threshold in
                    device.setTfliteThreshold(threshold)
                }
            #else
                HStack {
                    Text("Threshold \(String(format: "%.1f", threshold))")
                        .bold()
                        .frame(minWidth: minThresholdTextWidth, alignment: .leading)
                    Slider(
                        value: $threshold
                    ) { isEditingThreshold = $0 }
                }
                .onChange(of: isEditingThreshold) { _, isEditingThreshold in
                    if !isEditingThreshold {
                        device.setTfliteThreshold(threshold)
                    }
                }
            #endif

            #if os(tvOS) || os(watchOS)
                Picker("__Capture Delay__", selection: $captureDelay) {
                    ForEach(Array(stride(from: 0, through: BSTfliteFile.MaxCaptureDelay, by: 200)), id: \.self) { captureDelay in
                        Text("\(captureDelay)ms")
                            .tag(BSTfliteCaptureDelay(captureDelay))
                    }
                }.onChange(of: captureDelay) { _, captureDelay in
                    device.setTfliteCaptureDelay(captureDelay)
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
                    ) { isEditingCaptureDelay = $0 }
                }
                .onChange(of: isEditingCaptureDelay) { _, isEditingCaptureDelay in
                    if !isEditingCaptureDelay {
                        device.setTfliteCaptureDelay(captureDelay)
                    }
                }
            #endif
        } header: {
            Text("Inference Settings")
        }
        .onReceive(device.tfliteThresholdPublisher.dropFirst()) {
            if !isEditingThreshold {
                threshold = $0
            }
        }
        .onReceive(device.tfliteCaptureDelayPublisher.dropFirst()) {
            if !isEditingCaptureDelay {
                captureDelay = $0
            }
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
