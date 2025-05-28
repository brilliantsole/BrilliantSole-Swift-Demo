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

    @State private var cameraStatus: BSCameraStatus = .idle
    @State private var autoPicture: Bool = false

    var body: some View {
        Group {
            #if os(watchOS)
            VStack {
                CameraView(device: device)
            }
            #else
            ScrollView {
                CameraView(device: device)
                CameraControls(device: device, autoPicture: $autoPicture)
                Spacer()
            }
            #endif
        }
        .toolbar {
            let takePictureButton = Button {
                device.takePicture()
            } label: {
                Image(systemName: cameraStatus == .takingPicture ? "camera.fill" : "camera")
                    .accessibilityLabel("take picture")
            }

            let focusButton = Button {
                device.focusCamera()
            } label: {
                Image(systemName: cameraStatus == .focusing ? "eye.fill" : "eye")
                    .accessibilityLabel("focus camera")
            }

            let autoPictureButton = Button {
                autoPicture.toggle()
            } label: {
                Image(systemName: autoPicture ? "arrow.clockwise.circle.fill" : "arrow.clockwise.circle")
                    .accessibilityLabel("toggle auto picture")
            }

            #if os(watchOS)
            ToolbarItem(placement: .topBarTrailing) {
                takePictureButton
                    .foregroundColor(.primary)
            }
            ToolbarItem(placement: .bottomBar) {
                focusButton
                    .foregroundColor(.primary)
            }
            ToolbarItem(placement: .bottomBar) {
                autoPictureButton
                    .foregroundColor(.primary)
            }
            #else
            ToolbarItem {
                takePictureButton
            }
            ToolbarItem {
                autoPictureButton
            }
            ToolbarItem {
                focusButton
            }
            #endif
        }
        #if os(tvOS)
        .focusSection()
        #endif
        .navigationTitle("Camera")
        .onReceive(device.cameraStatusPubliher) {
            cameraStatus = $0
        }
        .onReceive(device.cameraImagePublisher) { _ in
            if autoPicture {
                device.takePicture()
            }
        }
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
    .frame(maxWidth: 300, minHeight: 500)
    #endif
}
