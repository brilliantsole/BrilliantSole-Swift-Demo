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
    let metaDevice: BSMetaDevice

    @State private var name: String = ""
    @State private var deviceType: BSDeviceType?
    @State private var ipAddress: String?

    init(metaDevice: BSMetaDevice) {
        self.metaDevice = metaDevice
        self.name = metaDevice.name
        self.deviceType = metaDevice.deviceType
        self.ipAddress = metaDevice.ipAddress
    }

    var deviceTypeSystemImage: String? {
        switch deviceType {
        case .leftInsole, .rightInsole:
            "shoe"
        case .leftGlove, .rightGlove:
            "hand.raised"
        case .glasses:
            "eyeglasses"
        case .generic:
            "questionmark"
        case nil:
            nil
        }
    }

    var body: some View {
        VStack(alignment: isWatch ? .center : .leading) {
            Text(name)
                .font(.title2)
                .bold()

            if let deviceType {
                HStack(spacing: 4) {
                    Image(systemName: deviceTypeSystemImage!)
                        .modify {
                            if deviceType == .leftInsole || deviceType == .rightGlove {
                                $0.scaleEffect(x: -1)
                            }
                        }
                    Text(deviceType.name)
                }
            }
            if let ipAddress {
                HStack(spacing: 4) {
                    Image(systemName: "wifi")
                    Text(ipAddress)
                }
            }
        }
        .onReceive(metaDevice.deviceTypePublisher) { newDeviceType in
            deviceType = newDeviceType
        }
        .onReceive(metaDevice.namePublisher) { newName in
            name = newName
        }
        .onReceive(metaDevice.ipAddressPublisher) { newIpAddress in
            ipAddress = newIpAddress
        }
    }
}

#Preview {
    DeviceRowHeader(metaDevice: BSDevice.mock)
    #if os(macOS)
        .frame(maxWidth: 350, minHeight: 300)
    #endif
}
