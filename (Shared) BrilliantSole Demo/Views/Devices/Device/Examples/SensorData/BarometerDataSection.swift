//
//  BarometerDataSection.swift
//  BrilliantSoleSwiftDemo
//
//  Created by Zack Qattan on 2/27/25.
//

import BrilliantSole
import Combine
import SwiftUI

struct BarometerDataSection: View {
    let device: BSDevice

    @State private var barometerData: BSBarometerData?

    var body: some View {
        let layout = isWatch ? AnyLayout(VStackLayout(alignment: .leading)) : AnyLayout(HStackLayout())

        Section {
            SensorRatePicker(device: device, sensorType: .barometer)
            if let barometerData {
                let timestamp = barometerData.timestamp
                
                layout {
                    Text("__Timestamp:__")
                    Text("[\(timestamp.timestampString)]")
                        .font(Font.system(.caption, design: .monospaced))
                }

                let barometer = barometerData.barometer
                layout {
                    Text("__Pressure:__")
                    Text("\(barometer)")
                        .font(Font.system(.caption, design: .monospaced))
                }
            }
        } header: {
            Text("Barometer Data")
                .font(.headline)
        }
        .onReceive(device.barometerPublisher) {
            barometerData = $0
        }
    }
}

#Preview {
    List {
        BarometerDataSection(device: .mock)
    }
    #if os(macOS)
    .frame(maxWidth: 350, minHeight: 300)
    #endif
}
