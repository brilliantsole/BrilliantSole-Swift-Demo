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
                #if os(watchOS)
                    if let uiImage = UIImage(data: imageData) {
                        GeometryReader { geometry in
                            Image(uiImage: uiImage)
                            #if os(watchOS)
                                .resizable()
                                .scaledToFill()
                                .clipped()
                                .edgesIgnoringSafeArea(.all)
                                .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
                            #else
                                .aspectRatio(contentMode: .fit)
                            #endif
                        }
                        .edgesIgnoringSafeArea(.all)
                    } else {
                        Text("Could not load image")
                    }
                #elseif os(iOS) || os(tvOS) || os(visionOS)
                    if let uiImage = UIImage(data: imageData) {
                        Image(uiImage: uiImage)
                            .resizable()
                        #if os(watchOS)
                            .aspectRatio(contentMode: .fill)
                        #else
                            .aspectRatio(contentMode: .fit)
                        #endif
                    } else {
                        Text("Could not load image")
                    }
                #elseif os(macOS)
                    if let nsImage = NSImage(data: imageData) {
                        Image(nsImage: nsImage)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                    } else {
                        Text("Could not load image")
                    }
                #else
                    Text("Unsupported platform")
                #endif
            } else {
                if device.isMock {
                    GeometryReader { geometry in
                        Image("sampleCameraImage")
                        #if os(watchOS)
                            .resizable()
                            .scaledToFill()
                            .clipped()
                            .edgesIgnoringSafeArea(.all)
                            .position(x: geometry.size.width / 2, y: geometry.size.height / 2) // Center the image
                        #else
                            .aspectRatio(contentMode: .fit)
                        #endif
                    }
                    .edgesIgnoringSafeArea(.all)
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
    NavigationStack {
        CameraExample(device: .mock)
    }
    #if os(macOS)
    .frame(maxWidth: 300, minHeight: 500)
    #endif
}
