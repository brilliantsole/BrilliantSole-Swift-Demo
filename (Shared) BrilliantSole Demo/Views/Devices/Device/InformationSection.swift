//
//  InformationSection.swift
//  BrilliantSoleSwiftDemo
//
//  Created by Zack Qattan on 2/18/25.
//

import BrilliantSole
import Combine
import SwiftUI

struct InformationSection: View {
    let device: BSDevice

    var canEdit: Bool {
        !isWatch && !isTv
    }

    @State private var name: String
    @State private var newName: String = ""

    @State private var deviceType: BSDeviceType
    @State private var newDeviceType: BSDeviceType

    @State private var batteryLevel: BSBatteryLevel

    init(device: BSDevice) {
        self.device = device
        _name = .init(initialValue: device.name)
        _deviceType = .init(initialValue: device.deviceType)
        _newDeviceType = .init(initialValue: device.deviceType)
        _batteryLevel = .init(initialValue: device.batteryLevel)
    }

    var body: some View {
        let layout = isWatch ? AnyLayout(VStackLayout()) : AnyLayout(HStackLayout())

        Section {
            HStack {
                Text("__name:__")
                Text(name)
                #if os(iOS)
                    .textSelection(.enabled)
                #endif
            }
            .onReceive(device.namePublisher) {
                self.name = $0
            }
            if canEdit {
                HStack {
                    TextField("new name", text: $newName)
                        .autocorrectionDisabled()
                    Button(action: {
                        device.setName(newName)
                        newName = ""
                    }) {
                        Text("update")
                    }
                    .disabled(newName.isEmpty)
                }
            }

            Picker("__device type__", selection: $newDeviceType) {
                ForEach(BSDeviceType.allCases) { deviceType in
                    Text(deviceType.name)
                }
            }
            .onChange(of: newDeviceType) {
                device.setDeviceType(newDeviceType)
            }

            if let connectionType = device.connectionType {
                HStack {
                    Text("__connection type:__")
                    Text(connectionType.name)
                    #if os(iOS)
                        .textSelection(.enabled)
                    #endif
                }
            }

        } header: {
            Text("Information")
                .font(.headline)
        }
    }
}

#Preview {
    List {
        InformationSection(device: .mock)
    }
    #if os(macOS)
    .frame(maxWidth: 410, minHeight: 300)
    #endif
}
