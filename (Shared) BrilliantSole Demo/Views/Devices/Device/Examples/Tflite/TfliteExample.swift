//
//  TfliteExample.swift
//  BrilliantSoleSwiftDemo
//
//  Created by Zack Qattan on 2/21/25.
//

import BrilliantSole
import Combine
import SwiftUI
import UkatonMacros
import UniformTypeIdentifiers

var tapStompKickTfliteModel: BSTfliteFile = .init(
    fileName: "tapStompKick",
    bundle: .main,
    modelName: "tapStompKick",
    sensorTypes: [.gyroscope, .linearAcceleration],
    task: .classification,
    sensorRate: ._10ms,
    captureDelay: 500,
    classes: ["idle", "kick", "stomp", "tap"]
)

@EnumName
enum TfliteModelMode: CaseIterable, Identifiable {
    public var id: Self { self }

    case tapStompKick
    case custom
}

struct TfliteExample: View {
    @EnvironmentObject var tfliteFileState: TfliteFileState

    let device: BSDevice

    @State private var selectedModelMode: TfliteModelMode = .tapStompKick

    @State private var fileTransferStatus: BSFileTransferStatus = .idle

    @State private var isTfliteInferencingEnabled = false

    var body: some View {
        List {
            TfliteModelSelectionSection(device: device, selectedModelMode: $selectedModelMode)
            TfliteUploadSection(device: device)
            TfliteModelSettings(device: device, selectedModelMode: $selectedModelMode)
            TfliteInferenceSettingsSection(device: device)
            TfliteInferencingSection(device: device)
            TfliteInferenceSection(device: device)
            TfliteClassificationSection(device: device)
        }
        .navigationTitle("Tflite")
        .onReceive(device.fileTransferStatusPublisher) {
            if device.fileType == .tflite { fileTransferStatus = $0 }
        }
        .onReceive(device.tfliteInferencingEnabledPublisher) {
            isTfliteInferencingEnabled = $0
        }
        .onDisappear {
            if isTfliteInferencingEnabled {
                device.disableTfliteInferencing(sendImmediately: false)
            }
            if fileTransferStatus != .idle {
                device.cancelFileTransfer(sendImmediately: false)
            }
            device.flushMessages()
        }
        .onDrop(of: [.init(filenameExtension: "tflite", conformingTo: .data) ?? .data], isTargeted: nil) { providers in
            for provider in providers {
                provider.loadInPlaceFileRepresentation(forTypeIdentifier: UTType.data.identifier) { url, _, _ in
                    DispatchQueue.main.async {
                        if let url, url.pathExtension == "tflite" {
                            print("Dropped file URL: \(url.absoluteString)")
                            tfliteFileState.tfliteFile.fileURL = url
                            selectedModelMode = .custom
                        }
                    }
                }
            }
            return true
        }
    }
}

#Preview {
    @Previewable @StateObject var tfliteFileState = TfliteFileState()

    NavigationStack {
        TfliteExample(device: .mock)
    }
    .environmentObject(tfliteFileState)
    #if os(macOS)
        .frame(maxWidth: 350, minHeight: 300)
    #endif
}
