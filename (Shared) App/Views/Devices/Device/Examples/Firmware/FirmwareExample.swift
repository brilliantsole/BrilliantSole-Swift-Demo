//
//  FirmwareExample.swift
//  BrilliantSoleSwiftDemo
//
//  Created by Zack Qattan on 2/22/25.
//

import BrilliantSole
import SwiftUI
import UkatonMacros
import UniformTypeIdentifiers

@EnumName
enum FirmwareFileMode: CaseIterable, Identifiable {
    public var id: Self { self }

    case builtIn
    case custom
}

struct FirmwareExample: View {
    let device: BSDevice

    @State private var selectedFirmwareFileMode: FirmwareFileMode = .builtIn
    @State private var selectedFirmwareFileUrl: URL? = nil

    var body: some View {
        List {
            FirmwareSelectionSection(device: device, selectedFirmwareFileMode: $selectedFirmwareFileMode, selectedFirmwareFileUrl: $selectedFirmwareFileUrl)
            FirmwareUploadSection(device: device)
        }
        .navigationTitle("Firmware")
        .onDisappear {
            if device.isFirmwareInProgress {
                device.cancelFirmwareUpgrade()
            }
        }
        #if os(macOS)
        .onDrop(of: [.init(filenameExtension: "bin", conformingTo: .data) ?? .data], isTargeted: nil) { providers in
            for provider in providers {
                provider.loadInPlaceFileRepresentation(forTypeIdentifier: UTType.data.identifier) { url, _, _ in
                    DispatchQueue.main.async {
                        if let url, url.pathExtension == "bin" {
                            print("Dropped file URL: \(url.absoluteString)")
                            selectedFirmwareFileUrl = url
                            selectedFirmwareFileMode = .custom
                        }
                    }
                }
            }
            return true
        }
        #endif
    }
}

#Preview {
    NavigationStack {
        FirmwareExample(device: .mock)
    }
    #if os(macOS)
    .frame(maxWidth: 350, minHeight: 300)
    #endif
}
