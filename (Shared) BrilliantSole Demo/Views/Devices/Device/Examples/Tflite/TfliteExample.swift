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

/**
 configure model
 enable model
 display results
 drag file to upload (macOS
 */

private var tapStompKickTfliteModel: BSTfliteFile = .init(
    fileName: "tapStompKick",
    bundle: .main,
    modelName: "tapStompKick",
    sensorTypes: [.gyroscope, .linearAcceleration],
    task: .classification,
    sensorRate: ._10ms,
    captureDelay: 500,
    classes: ["idle", "kick", "stomp", "tap"]
)

struct TfliteExample: View {
    let device: BSDevice

    @EnumName
    enum TfliteModels: CaseIterable, Identifiable {
        public var id: Self { self }

        case tapStompKick
        case custom
    }

    @State private var selectedModel: TfliteModels = .tapStompKick

    @State private var isSelectingFile: Bool = false
    @State private var selectedFileURL: URL? = nil

    @State private var uploadProgress: Float = 0.0
    @State private var fileTransferStatus: BSFileTransferStatus = .idle
    private var isUploading: Bool { fileTransferStatus == .sending }

    @EnvironmentObject var tfliteFileState: TfliteFileState

    private var tfliteFile: BSTfliteFile? {
        return switch selectedModel {
        case .tapStompKick:
            tapStompKickTfliteModel
        case .custom:
            tfliteFileState.tfliteFile
        }
    }

    var body: some View {
        List {
            #if !os(watchOS) && !os(tvOS)
                Picker("__Selected Model__", selection: $selectedModel) {
                    ForEach(TfliteModels.allCases) { model in
                        Text(model.name)
                            .tag(model)
                    }
                }.onChange(of: selectedModel) { _, _ in
                    // FILL - reset properties to tapStompKick
                    isSelectingFile = false
                }

                if selectedModel == .custom {
                    Button("Import Model (.tflite)", systemImage: "document") {
                        isSelectingFile = true
                    }
                    .fileImporter(
                        isPresented: $isSelectingFile,
                        allowedContentTypes: [.init(filenameExtension: "tflite", conformingTo: .data) ?? .data],
                        allowsMultipleSelection: false
                    ) { result in
                        do {
                            let urls = try result.get()
                            if let firstURL = urls.first, firstURL.pathExtension == "tflite" {
                                print("url: \(firstURL.absoluteString)")
                                selectedFileURL = firstURL
                            }
                        } catch {
                            print("File selection error: \(error.localizedDescription)")
                        }
                    }
                    .onChange(of: selectedFileURL) { _, newFileURL in
                        tfliteFileState.tfliteFile.fileURL = newFileURL
                    }

                    if let selectedFileURL {
                        Text("selected \(selectedFileURL.lastPathComponent)")
                    } else {
                        Text("no file selected")
                    }
                }

            #endif

            if var tfliteFile, tfliteFile.fileURL != nil {
                Button(action: {
                    device.sendTfliteModel(&tfliteFile)
                }) {
                    Label("Upload Model", systemImage: "arrow.up.document")
                }
                .disabled(fileTransferStatus != .idle)
            }

            if isUploading {
                VStack {
                    ProgressView(value: uploadProgress)
                    Button("Cancel") {
                        device.cancelFileTransfer()
                    }
                }
                .onReceive(device.fileTransferProgressPublisher) {
                    if $0.fileType == .tflite { uploadProgress = $0.progress }
                }
            }
        }
        .navigationTitle("Tflite")
        .onReceive(device.fileTransferStatusPublisher) {
            print("fileTransferStatus \($0.name)")
            if device.fileType == .tflite { fileTransferStatus = $0 }
        }
        .onDisappear {
            // FILL - cancel inferencing, file upload, etc
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
