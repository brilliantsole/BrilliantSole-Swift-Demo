//
//  TfliteUploadSection.swift
//  BrilliantSoleSwiftDemo
//
//  Created by Zack Qattan on 2/24/25.
//

import BrilliantSole
import Combine
import SwiftUI

struct TfliteUploadSection: View {
    let device: BSDevice

    @State private var uploadProgress: Float = 0.0

    @State private var fileTransferStatus: BSFileTransferStatus = .idle
    private var isUploading: Bool { fileTransferStatus == .sending }

    var body: some View {
        Group {
            if isUploading {
                Section {
                    VStack {
                        ProgressView(value: uploadProgress)
                        Button("Cancel") {
                            device.cancelFileTransfer()
                        }
                    }
                    .onReceive(device.fileTransferProgressPublisher) {
                        if $0.fileType == .tflite { uploadProgress = $0.progress }
                    }
                } header: {
                    Text("Uploading Model (\(Int(uploadProgress * 100))%)")
                }
            }
        }
        .onReceive(device.fileTransferStatusPublisher) {
            if device.fileType == .tflite { fileTransferStatus = $0 }
        }
    }
}

#Preview {
    List {
        TfliteUploadSection(device: .mock)
    }
    #if os(macOS)
    .frame(maxWidth: 350, minHeight: 300)
    #endif
}
