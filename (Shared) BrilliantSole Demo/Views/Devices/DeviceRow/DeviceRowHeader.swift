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

    init(metaDevice: BSMetaDevice) {
        self.metaDevice = metaDevice
        self.name = metaDevice.name
        self.deviceType = metaDevice.deviceType
    }

    var deviceTypeSystemImage: String? {
        switch deviceType {
        case .leftInsole, .rightInsole:
            "shoe"
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
                            if deviceType == .leftInsole {
                                $0.scaleEffect(x: -1)
                            }
                        }
                    Text(deviceType.name)
                }
            }
        }
        .onReceive(metaDevice.deviceTypePublisher) { newDeviceType in
            deviceType = newDeviceType
        }
        .onReceive(metaDevice.namePublisher) { newName in
            name = newName
        }
    }
}

#Preview {
    DeviceRowHeader(metaDevice: BSDevice.mock)
    #if os(macOS)
        .frame(maxWidth: 350, minHeight: 300)
    #endif
}
