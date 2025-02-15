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
    @State private var deviceType: BSDeviceType? = nil

    var body: some View {
        GenericDeviceRowHeader(name: name, deviceType: deviceType)
            .onReceive(device.deviceTypePublisher) { _, newDeviceType in
                deviceType = newDeviceType
            }
            .onReceive(device.namePublisher) { _, newName in
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
