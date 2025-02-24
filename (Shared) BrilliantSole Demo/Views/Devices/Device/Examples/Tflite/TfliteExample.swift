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

struct TfliteExample: View {
    let device: BSDevice

    @EnumName
    enum TfliteModels: CaseIterable, Identifiable {
        public var id: Self { self }

        case tapStompKick
        case custom
    }

    @State private var selectedModel: TfliteModels = .tapStompKick
    private func onSelectedModelUpdate() {}

    @State private var isSelectingFile: Bool = false
    @State private var selectedFileURL: URL? = nil

    @State private var uploadProgress: Float = 0.0
    @State private var fileTransferStatus: BSFileTransferStatus = .idle
    private var isUploading: Bool { fileTransferStatus == .sending }

    @State private var classification: BSTfliteClassification? = (
        name: "Stomp",
        value: 1.0,
        timestamp: 0
    )
    @State private var inference: BSTfliteInference? = (
        values: [0.359608, 0.029498, 0.118994, 0.491900],
        valueMap: ["idle": 0.359608, "kick": 0.029498, "stomp": 0.118994, "tap": 0.491900],
        timestamp: 0
    )

    @EnvironmentObject var tfliteFileState: TfliteFileState

    private var tfliteFile: BSTfliteFile? {
        return switch selectedModel {
        case .tapStompKick:
            tapStompKickTfliteModel
        case .custom:
            tfliteFileState.tfliteFile
        }
    }

    var canEdit: Bool {
        !isWatch && !isTv && selectedModel == .custom
    }

    @State private var isReady = false
    @State private var isEnabled = false

    var body: some View {
        List {
            Section {
                #if !os(watchOS) && !os(tvOS)
                    Picker("__Selected Model__", selection: $selectedModel) {
                        ForEach(TfliteModels.allCases) { model in
                            Text(model.name)
                                .tag(model)
                        }
                    }.onChange(of: selectedModel) { _, _ in
                        onSelectedModelUpdate()
                    }
                #endif

                if var tfliteFile {
                    Button(action: {
                        device.sendTfliteModel(&tfliteFile)
                    }) {
                        Label("Upload Model", systemImage: "arrow.up.document")
                    }
                    .disabled(tfliteFile.fileURL == nil || fileTransferStatus != .idle)
                }

                #if !os(watchOS) && !os(tvOS)
                    if selectedModel == .custom {
                        Button("Select Model (.tflite)", systemImage: "document") {
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
                            Text("No File Selected")
                        }
                    }
                #endif
            } header: {
                Text("Model File")
            }

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
                    Text("Uploading File...")
                }
            }

            Section {
                if canEdit {
                    TextField("Model Name", text: $tfliteFileState.tfliteFile.modelName)
                        .autocorrectionDisabled()
                        .disabled(isEnabled)
                } else {
                    Text("__Model Name:__ \(tapStompKickTfliteModel.modelName)")
                }

                if canEdit {
                    Picker("__Task__", selection: $tfliteFileState.tfliteFile.task) {
                        ForEach(BSTfliteTask.allCases) { task in
                            Text(task.name)
                        }
                    }
                    .disabled(isEnabled)
                } else {
                    Text("__Task:__ \(tapStompKickTfliteModel.task.name)")
                }

                if canEdit {
                    Picker("__Sensor Rate__", selection: $tfliteFileState.tfliteFile.sensorRate) {
                        ForEach(BSSensorRate.allCases.filter { $0.rawValue > 0 }) { sensorRate in
                            Text(sensorRate.name)
                        }
                    }
                    .disabled(isEnabled)
                } else {
                    Text("__Sensor Rate:__ \(tapStompKickTfliteModel.sensorRate.name)")
                }

                if canEdit {
                    ForEach(BSTfliteSensorType.allCases) { sensorType in
                        Toggle(sensorType.name, isOn: Binding(
                            get: { tfliteFileState.tfliteFile.sensorTypes.contains(sensorType) },
                            set: { isSelected in
                                if isSelected {
                                    tfliteFileState.tfliteFile.sensorTypes.insert(sensorType)
                                } else {
                                    tfliteFileState.tfliteFile.sensorTypes.remove(sensorType)
                                }
                            }
                        ))
                    }
                    .disabled(isEnabled)
                } else {
                    Text("__Sensor Types:__ \(tapStompKickTfliteModel.sensorTypes.map(\.name).joined(separator: ", "))")
                }
            } header: {
                Text("Model Settings")
            }

            Section {
                Text("Threshold")
                Text("Capture Delay")
            } header: {
                Text("Inferencing Settings")
            }

            Section {
                Text("__Is Ready?__ \(isReady ? "Yes" : "No")")
                    .onReceive(device.isTfliteReadyPublisher) { isReady = $0 }

                if isReady {
                    Button(isEnabled ? "disable model" : "enable model") {
                        device.toggleTfliteInferencingEnabled()
                    }
                    .onReceive(device.tfliteInferencingEnabledPublisher) { isEnabled = $0 }
                }
            } header: {
                Text("Inferencing")
            }
            .onReceive(device.tfliteInferencePublisher) { inference = $0 }
            .onReceive(device.tfliteClassificationPublisher) { classification = $0 }

            if let inference {
                Section {
                    Text("__Timestamp__: \(inference.timestamp)")
                    if let valueMap = inference.valueMap {
                        ForEach(valueMap.sorted(by: { $0.value > $1.value }), id: \.key) { key, value in
                            Text("__\(key):__ \(value)")
                        }
                    } else {
                        ForEach(Array(inference.values.enumerated()), id: \.offset) { index, value in
                            Text("__#\(index + 1):__ \(value)")
                        }
                    }
                } header: {
                    Text("Inference")
                }
            }

            if let classification {
                Section {
                    Text("__Timestamp__: \(classification.timestamp)")
                    Text("__Classification__: \(classification.name)")
                    Text("__Value__: \(classification.value)")
                } header: {
                    Text("Classification")
                }
            }
        }
        .navigationTitle("Tflite")
        .onReceive(device.fileTransferStatusPublisher) {
            if device.fileType == .tflite { fileTransferStatus = $0 }
        }
        .onDisappear {
            if isEnabled {
                device.disableTfliteInferencing(sendImmediately: false)
            }
            if fileTransferStatus != .idle {
                device.cancelFileTransfer(sendImmediately: false)
            }
            device.flushMessages()
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
