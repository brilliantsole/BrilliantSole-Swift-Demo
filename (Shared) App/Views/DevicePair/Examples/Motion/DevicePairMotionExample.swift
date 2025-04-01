//
//  DevicePairMotionExample.swift
//  BrilliantSoleSwiftDemo
//
//  Created by Zack Qattan on 2/27/25.
//

import BrilliantSole
import Combine
import SwiftUI

struct DevicePairMotionExample: View {
    let devicePair: BSDevicePair

    private let recalibrateSubject: PassthroughSubject<Void, Never> = .init()

    var body: some View {
        VStack {
            HStack {
                ModelView(device: devicePair[.left] ?? .mock, recalibrateSubject: recalibrateSubject)
                ModelView(device: devicePair[.right] ?? .mock, recalibrateSubject: recalibrateSubject)
            }
            RotationModePicker(sensorConfigurable: devicePair)
            TranslationModePicker(sensorConfigurable: devicePair)
        }
        #if os(tvOS)
        .focusSection()
        #endif
        .navigationTitle("Motion")
        .onDisappear {
            devicePair.clearSensorConfiguration()
        }
        .toolbar {
            let button = Button {
                recalibrateSubject.send(())
            } label: {
                Image(systemName: "arrow.counterclockwise")
                    .accessibilityLabel("reset orientation")
            }
            #if os(watchOS)
            ToolbarItem(placement: .topBarTrailing) {
                button
                    .foregroundColor(.primary)
            }
            #else
            ToolbarItem {
                button
            }
            #endif
        }
    }
}

#Preview {
    NavigationStack {
        DevicePairMotionExample(devicePair: .insoles)
    }
    #if os(macOS)
    .frame(maxWidth: 500, minHeight: 300)
    #endif
}
