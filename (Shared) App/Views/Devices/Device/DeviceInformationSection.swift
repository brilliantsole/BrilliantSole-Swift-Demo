//
//  DeviceInformationSection.swift
//  BrilliantSoleSwiftDemo
//
//  Created by Zack Qattan on 2/18/25.
//

import BrilliantSole
import Combine
import SwiftUI

struct DeviceInformationSection: View {
    let device: BSDevice

    @State private var deviceInformation: BSDeviceInformation

    init(device: BSDevice) {
        self.device = device
        self._deviceInformation = .init(initialValue: device.deviceInformation)
    }

    var body: some View {
        let layout = isWatch ? AnyLayout(VStackLayout()) : AnyLayout(HStackLayout())

        Section {
            ForEach(Array(deviceInformation.keys).sorted(), id: \.self) { key in
                layout {
                    Text("__\(key.name):__")
                    Text(deviceInformation[key]!)
                    #if os(iOS)
                        .textSelection(.enabled)
                    #endif
                }
            }
        } header: {
            Text("Device Information")
                .font(.headline)
        }
        .onReceive(device.deviceInformationPublisher) {
            self.deviceInformation = $0
        }
    }
}

#Preview {
    List {
        DeviceInformationSection(device: .mock)
    }
    #if os(macOS)
    .frame(maxWidth: 410, minHeight: 300)
    #endif
}
