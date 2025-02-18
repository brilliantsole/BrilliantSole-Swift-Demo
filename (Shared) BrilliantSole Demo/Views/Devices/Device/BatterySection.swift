//
//  BatterySection.swift
//  BrilliantSoleSwiftDemo
//
//  Created by Zack Qattan on 2/18/25.
//

import BrilliantSole
import Combine
import SwiftUI

struct BatterySection: View {
    let device: BSDevice

    @State private var batteryLevel: BSBatteryLevel
    @State private var batteryCurrent: Float
    @State private var isBatteryCharging: Bool

    init(device: BSDevice) {
        self.device = device
        _batteryLevel = .init(initialValue: device.batteryLevel)
        _batteryCurrent = .init(initialValue: device.batteryCurrent)
        _isBatteryCharging = .init(initialValue: device.isBatteryCharging)
    }

    var body: some View {
        let layout = isWatch ? AnyLayout(VStackLayout()) : AnyLayout(HStackLayout())

        Section {
            HStack {
                Text("__battery level:__")
                Text("\(String(batteryLevel))%")
            }
            .onReceive(device.batteryLevelPublisher) { batteryLevel = $0
            }

            HStack {
                Text("__is battery charging:__")
                Text("\(String(isBatteryCharging))")
            }
            .onReceive(device.isBatteryChargingPublisher) { isBatteryCharging = $0
            }

            layout {
                layout {
                    Text("__battery current:__")
                    Text("\(String(batteryCurrent))mAh")
                }
                Button(action: {
                    device.getBatteryCurrent()
                }) {
                    Label("refresh", systemImage: "arrow.clockwise")
                }
            }
            .onReceive(device.batteryCurrentPublisher) { batteryCurrent = $0
            }

        } header: {
            Text("Battery")
                .font(.headline)
        }
    }
}

#Preview {
    List {
        BatterySection(device: .mock)
    }
    #if os(macOS)
    .frame(maxWidth: 410, minHeight: 300)
    #endif
}
