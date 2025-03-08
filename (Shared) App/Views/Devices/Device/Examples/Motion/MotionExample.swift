//
//  MotionExample.swift
//  BrilliantSoleSwiftDemo
//
//  Created by Zack Qattan on 2/18/25.
//

import BrilliantSole
import Combine
import SwiftUI

struct MotionExample: View {
    let device: BSDevice

    private let recalibrateSubject: PassthroughSubject<Void, Never> = .init()

    var body: some View {
        VStack {
            ModelView(device: device, recalibrateSubject: recalibrateSubject)
            #if os(tvOS)
                .focusSection()
            #endif
            RotationModePicker(sensorConfigurable: device)
            #if os(tvOS)
                .focusSection()
            #endif
            TranslationModePicker(sensorConfigurable: device)
            #if os(tvOS)
                .focusSection()
            #endif
        }
        #if os(tvOS)
        .focusSection()
        #endif
        .navigationTitle("Motion")
        .onDisappear {
            device.clearSensorConfiguration()
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
    MotionExample(device: .mock)
    #if os(macOS)
        .frame(maxWidth: 350, minHeight: 300)
    #endif
}
