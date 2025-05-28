//
//  CameraView.swift
//  BrilliantSoleSwiftDemo
//
//  Created by Zack Qattan on 5/27/25.
//

import BrilliantSole
import Combine
import SwiftUI

struct CameraView: View {
    let device: BSDevice

    init(device: BSDevice) {
        self.device = device
    }

    @State private var imageData: Data?

    var body: some View {
        ZStack {
            if let imageData {
                #if os(iOS) || os(tvOS) || os(watchOS) || os(visionOS)
                    if let uiImage = UIImage(data: imageData) {
                        Image(uiImage: uiImage)
                        #if os(watchOS)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                        #else
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .edgesIgnoringSafeArea(.all)
                        #endif
                    } else {
                        Text("Could not load image")
                    }
                #elseif os(macOS)
                    if let nsImage = NSImage(data: imageData) {
                        Image(nsImage: nsImage)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .cornerRadius(12)
                    } else {
                        Text("Could not load image")
                    }
                #else
                    Text("Unsupported platform")
                #endif
            } else {
                if device.isMock {
                    Image("sampleCameraImage")
                    #if os(watchOS)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                    #endif
                } else {
                    Text("take picture")
                }
            }
        }
        .onReceive(device.cameraImagePublisher) {
            imageData = $0
        }
    }
}

#Preview {
    CameraView(device: .mock)
    #if os(macOS)
        .frame(maxWidth: 360, maxHeight: 300)
    #endif
}
