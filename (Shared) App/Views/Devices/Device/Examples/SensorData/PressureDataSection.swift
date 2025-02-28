//
//  PressureDataSection.swift
//  BrilliantSoleSwiftDemo
//
//  Created by Zack Qattan on 2/27/25.
//

import BrilliantSole
import Combine
import SwiftUI

struct PressureDataSection: View {
    let device: BSDevice

    @State private var pressureDataTuple: BSPressureDataTuple?

    private let nf: NumberFormatter = {
        let nf = NumberFormatter()
        nf.numberStyle = .decimal
        nf.minimumIntegerDigits = 1
        nf.minimumFractionDigits = 5
        nf.maximumFractionDigits = 5
        nf.positivePrefix = " "
        nf.paddingCharacter = "0"
        nf.paddingPosition = .afterSuffix
        return nf
    }()

    var body: some View {
        let layout = isWatch ? AnyLayout(VStackLayout(alignment: .leading)) : AnyLayout(HStackLayout())

        Section {
            SensorRatePicker(device: device, sensorType: .pressure)
            if let pressureDataTuple {
                let timestamp = pressureDataTuple.timestamp

                layout {
                    Text("__Timestamp:__")
                    Text("[\(timestamp.timestampString)]")
                        .font(Font.system(.caption, design: .monospaced))
                }

                let pressureData = pressureDataTuple.pressure
                layout {
                    Text("__Raw Values:__")
                    let string = pressureData.sensors.map { String(format: "%4d", $0.rawValue) }.joined(separator: ", ")
                    Text(string)
                        .font(Font.system(.caption, design: .monospaced))
                }
                layout {
                    Text("__Normalized Values:__")
                    let string = pressureData.sensors.map { nf.string(for: $0.normalizedValue)! }.joined(separator: ", ")
                    Text(string)
                        .font(Font.system(.caption, design: .monospaced))
                }
                layout {
                    Text("__Scaled Values__")
                    let string = pressureData.sensors.map { nf.string(for: $0.scaledValue)! }.joined(separator: ", ")
                    Text(string)
                        .font(Font.system(.caption, design: .monospaced))
                }
                layout {
                    Text("__Weighted Values__")
                    let string = pressureData.sensors.map { nf.string(for: $0.weightedValue)! }.joined(separator: ", ")
                    Text(string)
                        .font(Font.system(.caption, design: .monospaced))
                }
                layout {
                    Text("__Normalized Sum__")
                    let string = nf.string(for: pressureData.normalizedSum)!
                    Text(string)
                        .font(Font.system(.caption, design: .monospaced))
                }
                layout {
                    Text("__Scaled Sum__")
                    let string = nf.string(for: pressureData.scaledSum)!
                    Text(string)
                        .font(Font.system(.caption, design: .monospaced))
                }

                if let centerOfPressure = pressureData.centerOfPressure {
                    layout {
                        Text("__Center of Pressure__")
                        Text(centerOfPressure.centerOfPressureString)
                            .font(Font.system(.caption, design: .monospaced))
                    }
                }
                if let normalizedCenterOfPressure = pressureData.normalizedCenterOfPressure {
                    layout {
                        Text("__Normalized Center of Pressure__")
                        Text(normalizedCenterOfPressure.centerOfPressureString)
                            .font(Font.system(.caption, design: .monospaced))
                    }
                }
            }
        } header: {
            Text("Pressure Data")
                .font(.headline)
        }
        .onReceive(device.pressureDataPublisher) {
            pressureDataTuple = $0
        }
    }
}

#Preview {
    List {
        PressureDataSection(device: .mock)
    }
    #if os(macOS)
    .frame(maxWidth: 350, minHeight: 300)
    #endif
}
