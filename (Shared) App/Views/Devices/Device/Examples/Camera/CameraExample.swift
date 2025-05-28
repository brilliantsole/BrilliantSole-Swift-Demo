//
//  CameraExample.swift
//  BrilliantSoleSwiftDemo
//
//  Created by Zack Qattan on 5/25/25.
//

import BrilliantSole
import Combine
import SwiftUI

struct CameraExample: View {
    let device: BSDevice

    func takePicture() {
        device.takePicture()
    }

    var body: some View {
        VStack {
            CameraView(device: device)
        }
        .toolbar {
            let takePictureButton = Button {
                takePicture()
            } label: {
                Image(systemName: "camera.fill")
                    .accessibilityLabel("take picture")
            }
            #if os(watchOS)
            ToolbarItem(placement: .topBarTrailing) {
                takePictureButton
                    .foregroundColor(.primary)
            }
            #else
            ToolbarItem {
                takePictureButton
            }
            #endif
        }
        #if os(tvOS)
        .focusSection()
        #endif
        .navigationTitle("Camera")
        .onDisappear {
            device.clearSensorRate(sensorType: .camera)
        }
        .onAppear {
            device.setSensorRate(sensorType: .camera, sensorRate: ._5ms)
        }
    }
}

#Preview {
    NavigationStack {
        CameraExample(device: .mock)
    }
    #if os(macOS)
    .frame(maxWidth: 350, minHeight: 300)
    #endif
}
