//
//  FirmwareSelectionSection.swift
//  BrilliantSoleSwiftDemo
//
//  Created by Zack Qattan on 2/26/25.
//

import BrilliantSole
import Combine
import SwiftUI
import UkatonMacros

struct FirmwareSelectionSection: View {
    let device: BSDevice
    @Binding var selectedFirmwareFileMode: FirmwareFileMode
    @State private var upgradeState: BSFirmwareUpgradeState = .none

    @State private var isSelectingFile = false
    @State private var isFirmwareResetting = false

    let defaultFirmwareUrl = Bundle.main.url(forResource: "firmware", withExtension: "bin")

    private func stopAccessingCurrentFileURL() {
        if let fileUrl = selectedFirmwareFileUrl {
            fileUrl.stopAccessingSecurityScopedResource()
        }
    }

    @Binding var selectedFirmwareFileUrl: URL?
    private var firmwareFileUrl: URL? {
        return switch selectedFirmwareFileMode {
        case .builtIn:
            defaultFirmwareUrl
        case .custom:
            selectedFirmwareFileUrl
        }
    }

    var body: some View {
        Section {
            Text("__Status:__ \(String(describing: upgradeState))")
            Text("__Is Resetting:__ \(isFirmwareResetting ? "Yes" : "No")")

            #if !os(watchOS) && !os(tvOS)
            Picker("__Selected Firmware__", selection: $selectedFirmwareFileMode) {
                ForEach(FirmwareFileMode.allCases) { mode in
                    Text(mode.name)
                        .tag(mode)
                }
            }
            #endif

            if let firmwareFileUrl {
                Button(action: {
                    device.upgradeFirmware(url: firmwareFileUrl)
                }) {
                    Label("Upload Firmware", systemImage: "arrow.up.document")
                }
                .disabled(upgradeState != .none)
            }

            #if !os(watchOS) && !os(tvOS)
            if selectedFirmwareFileMode == .custom {
                Button("Select Firmware (.bin)", systemImage: "document") {
                    isSelectingFile = true
                }
                .fileImporter(
                    isPresented: $isSelectingFile,
                    allowedContentTypes: [.init(filenameExtension: "bin", conformingTo: .data) ?? .data],
                    allowsMultipleSelection: false
                ) { result in
                    do {
                        let urls = try result.get()
                        if let firstURL = urls.first, firstURL.pathExtension == "bin" {
                            print("Selected URL: \(firstURL)")
                            stopAccessingCurrentFileURL()
                            if firstURL.startAccessingSecurityScopedResource() {
                                selectedFirmwareFileUrl = firstURL
                            } else {
                                print("Failed to access file security-scoped resource")
                            }
                        }
                    } catch {
                        print("File selection error: \(error.localizedDescription)")
                    }
                }
                .onDisappear {
                    stopAccessingCurrentFileURL()
                }

                if let selectedFirmwareFileUrl {
                    Text("selected _\(selectedFirmwareFileUrl.lastPathComponent)_")
                } else {
                    Text("No File Selected")
                }
            }
            #endif
        } header: {
            Text("Firmware File")
        }
        .onReceive(device.firmwareUpgradeStatePublisher) {
            upgradeState = $0
        }
        .onReceive(device.isFirmwareResettingPublisher) {
            isFirmwareResetting = $0
        }
    }
}

#Preview {
    List {
        FirmwareSelectionSection(device: .mock, selectedFirmwareFileMode: .constant(.builtIn), selectedFirmwareFileUrl: .constant(nil))
    }
    #if os(macOS)
    .frame(maxWidth: 350, minHeight: 300)
    #endif
}
