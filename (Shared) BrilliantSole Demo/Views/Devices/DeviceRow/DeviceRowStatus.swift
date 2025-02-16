//
//  DeviceRowStatus.swift
//  BrilliantSoleSwiftDemo
//
//  Created by Zack Qattan on 2/13/25.
//

import BrilliantSole
import Combine
import SwiftUI

struct DeviceRowStatus: View {
    let device: BSDevice

    @State private var isConnected: Bool = false

    @State private var batteryLevel: BSBatteryLevel = .zero
    private var batteryLevelSystemImage: String {
        switch batteryLevel {
        case 85 ... 100:
            "battery.100"
        case 65 ... 85:
            "battery.75"
        case 35 ... 65:
            "battery.50"
        case 15 ... 35:
            "battery.25"
        default:
            "battery.0"
        }
    }

    private var batteryLevelColor: Color {
        switch batteryLevel {
        case 70 ... 100:
            .green
        case 25 ... 70:
            .orange
        case 0 ... 25:
            .red
        default:
            .red
        }
    }

    init(device: BSDevice) {
        self.device = device
        _isConnected = .init(initialValue: device.isConnected)
        _batteryLevel = .init(initialValue: device.batteryLevel)
    }

    var body: some View {
        let layout = isWatch ? AnyLayout(VStackLayout()) : AnyLayout(HStackLayout(spacing: 15))

        layout {
            if isConnected {
                Label {
                    Text("\(batteryLevel)%")
                } icon: {
                    Image(systemName: batteryLevelSystemImage)
                        .foregroundColor(batteryLevelColor)
                }
            }
        }
        .onReceive(device.batteryLevelPublisher, perform: { newBatteryLevel in batteryLevel = newBatteryLevel
        })
        .onReceive(device.isConnectedPublisher, perform: { newIsConnected in isConnected = newIsConnected
        })
        .labelStyle(LabelSpacing(spacing: 4))
        .font(Font.system(isWatch ? .caption2 : .caption, design: .monospaced))
        .padding(.top, 2)
    }
}

#Preview {
    DeviceRowStatus(device: .mock)
    #if os(macOS)
        .frame(maxWidth: 350, minHeight: 300)
    #endif
}
