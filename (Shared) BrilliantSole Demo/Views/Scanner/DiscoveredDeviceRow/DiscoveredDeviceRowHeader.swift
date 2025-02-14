//
//  DiscoveredDeviceRowHeader.swift
//  BrilliantSoleSwiftDemo
//
//  Created by Zack Qattan on 2/13/25.
//

import BrilliantSole
import SwiftUI

struct DiscoveredDeviceRowHeader: View {
    let discoveredDevice: BSDiscoveredDevice

    @State private var name: String = ""
    @State private var deviceType: BSDeviceType? = nil

    var deviceTypeSystemImage: String? {
        switch discoveredDevice.deviceType {
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
        .onReceive(discoveredDevice.deviceTypePublisher) { _, newDeviceType in
            deviceType = newDeviceType
        }
        .onReceive(discoveredDevice.namePublisher) { _, newName in
            name = newName
        }
    }
}

#Preview {
    DiscoveredDeviceRowHeader(discoveredDevice: .none)
    #if os(macOS)
        .frame(maxWidth: 350, minHeight: 300)
    #endif
}
