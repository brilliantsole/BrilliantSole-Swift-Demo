//
//  CameraControls.swift
//  BrilliantSoleSwiftDemo
//
//  Created by Zack Qattan on 5/25/25.
//

import BrilliantSole
import Combine
import SwiftUI

struct CameraControls: View {
    let device: BSDevice

    @State private var cameraImageProgress: Float = 0.0
    @State private var cameraStatus: BSCameraStatus = .idle

    @Binding var autoPicture: Bool

    init(device: BSDevice, autoPicture: Binding<Bool>) {
        self.device = device
        self._autoPicture = autoPicture
    }

    var body: some View {
        VStack {
            HStack(spacing: 10) {
                Button(cameraStatus == .takingPicture ? "\(Int(cameraImageProgress * 100))%" : "Take Picture") {
                    device.takePicture()
                }
                .buttonStyle(.borderedProminent)
                .disabled(cameraStatus != .idle)
                Button(cameraStatus == .focusing ? "Focusing" : "Focus") {
                    device.focusCamera()
                }
                .buttonStyle(.borderedProminent)
                .disabled(cameraStatus != .idle)
                Button(cameraStatus == .asleep ? "Wake" : "Sleep") {
                    device.toggleCameraWake()
                }
                .buttonStyle(.borderedProminent)
                .disabled(cameraStatus == .takingPicture || cameraStatus == .focusing)

                Button(autoPicture ? "Video" : "Camera") {
                    autoPicture.toggle()
                }
                .buttonStyle(.borderedProminent)
                .disabled(cameraStatus == .takingPicture || cameraStatus == .focusing)
            }
            
        }
        .onReceive(device.cameraStatusPubliher) {
            cameraStatus = $0
        }
        .onReceive(device.cameraImageProgressPublisher) {
            cameraImageProgress = $0
        }
    }
}

#Preview {
    NavigationStack {
        CameraExample(device: .mock)
    }
    #if os(macOS)
    .frame(maxWidth: 300, minHeight: 500)
    #endif
}
