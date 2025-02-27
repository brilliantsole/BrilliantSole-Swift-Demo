//
//  FirmwareUploadSection.swift
//  BrilliantSoleSwiftDemo
//
//  Created by Zack Qattan on 2/26/25.
//

import BrilliantSole
import Combine
import SwiftUI

struct FirmwareUploadSection: View {
    let device: BSDevice

    @State private var upgradeState: BSFirmwareUpgradeState = .none
    @State private var uploadProgress: Float = 0.0

    var body: some View {
        Group {
            if upgradeState == .upload {
                Section {
                    VStack {
                        ProgressView(value: uploadProgress)
                        Button("Cancel") {
                            device.cancelFirmwareUpgrade()
                        }
                    }
                    .onReceive(device.firmwareUploadProgressDidChangePublisher) {
                        uploadProgress = $0.progress
                    }
                } header: {
                    Text("Uploading Firmware (\(Int(uploadProgress * 100))%)")
                }
            }
        }
        .onReceive(device.firmwareUpgradeStatePublisher) {
            upgradeState = $0
        }
    }
}

#Preview {
    List {
        FirmwareUploadSection(device: .mock)
    }
    #if os(macOS)
    .frame(maxWidth: 350, minHeight: 300)
    #endif
}
