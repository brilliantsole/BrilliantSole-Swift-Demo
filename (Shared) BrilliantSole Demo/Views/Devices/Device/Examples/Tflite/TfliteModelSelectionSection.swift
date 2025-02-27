//
//  TfliteModelSelectionSection.swift
//  BrilliantSoleSwiftDemo
//
//  Created by Zack Qattan on 2/24/25.
//

import BrilliantSole
import Combine
import SwiftUI

struct TfliteModelSelectionSection: View {
    let device: BSDevice
    @Binding var selectedModelMode: TfliteModelMode
    @EnvironmentObject var tfliteFileState: TfliteFileState

    @State private var isSelectingFile: Bool = false

    @State private var fileTransferStatus: BSFileTransferStatus = .idle

    private var tfliteFile: BSTfliteFile? {
        return switch selectedModelMode {
        case .tapStompKick:
            tapStompKickTfliteModel
        case .custom:
            tfliteFileState.tfliteFile
        }
    }

    var body: some View {
        Section {
            #if !os(watchOS) && !os(tvOS)
                Picker("__Selected Model__", selection: $selectedModelMode) {
                    ForEach(TfliteModelMode.allCases) { model in
                        Text(model.name)
                            .tag(model)
                    }
                }
            #endif

            if var tfliteFile {
                Button(action: {
                    print("sending tfliteModel")
                    device.sendTfliteModel(&tfliteFile)
                }) {
                    Label("Upload Model", systemImage: "arrow.up.document")
                }
                .disabled(tfliteFile.fileURL == nil || fileTransferStatus != .idle)
            }

            #if !os(watchOS) && !os(tvOS)
                if selectedModelMode == .custom {
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
                                print("Selected URL: \(firstURL)")

                                if firstURL.startAccessingSecurityScopedResource() {
                                    tfliteFileState.tfliteFile.fileURL = firstURL
                                } else {
                                    print("Failed to access file security-scoped resource")
                                }
                            }
                        } catch {
                            print("File selection error: \(error.localizedDescription)")
                        }
                    }
                    .onDisappear {
                        if let fileUrl = tfliteFileState.tfliteFile.fileURL {
                            fileUrl.stopAccessingSecurityScopedResource()
                        }
                    }

                    if let fileURL = tfliteFileState.tfliteFile.fileURL {
                        Text("selected \(fileURL.lastPathComponent)")
                    } else {
                        Text("No File Selected")
                    }
                }
            #endif
        } header: {
            Text("Model File")
        }
        .onReceive(device.fileTransferStatusPublisher) {
            if device.fileType == .tflite { fileTransferStatus = $0 }
        }
    }
}

#Preview {
    @Previewable @StateObject var tfliteFileState = TfliteFileState()
    @Previewable @State var selectedModelMode: TfliteModelMode = .tapStompKick

    List {
        TfliteModelSelectionSection(device: .mock, selectedModelMode: $selectedModelMode)
    }
    .environmentObject(tfliteFileState)
    #if os(macOS)
        .frame(maxWidth: 350, minHeight: 300)
    #endif
}
