//
//  DeviceRowHeader.swift
//  BrilliantSoleSwiftDemo
//
//  Created by Zack Qattan on 2/13/25.
//

import BrilliantSole
import Combine
import SwiftUI

struct DeviceRowHeader: View {
    let device: BSDevice

    @State private var name: String = ""
    @State private var deviceType: BSDeviceType?

    init(device: BSDevice) {
        self.device = device
        self.name = device.name
        self.deviceType = device.deviceType
    }

    var body: some View {
        GenericDeviceRowHeader(name: name, deviceType: deviceType)
            .onReceive(device.deviceTypePublisher) { newDeviceType in
                deviceType = newDeviceType
            }
            .onReceive(device.namePublisher) { newName in
                name = newName
            }
    }
}

#Preview {
    DeviceRowHeader(device: .none)
    #if os(macOS)
        .frame(maxWidth: 350, minHeight: 300)
    #endif
}
