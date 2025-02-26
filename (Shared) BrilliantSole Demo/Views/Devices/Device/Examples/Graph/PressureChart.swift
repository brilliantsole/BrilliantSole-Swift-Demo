//
//  PressureChart.swift
//  BrilliantSoleSwiftDemo
//
//  Created by Zack Qattan on 2/25/25.
//

import BrilliantSole
import Charts
import Combine
import SwiftUI

struct PressureChart: View {
    let device: BSDevice
    let sensorType: BSSensorType = .barometer
    @Binding var maxDataPoints: Int
    @State private var dataArray: [BSPressureDataTuple] = []
    private let chartYScaleDomain: ClosedRange<Float> = 0 ... 1

    private var publisher: BSPressureDataPublisher? {
        device.pressureDataPublisher
    }

    func trimDataPoints() {
        if dataArray.count > maxDataPoints {
            dataArray.removeFirst(dataArray.count - maxDataPoints)
        }
    }

    init(device: BSDevice, maxDataPoints: Binding<Int>) {
        self.device = device
        self._maxDataPoints = maxDataPoints
        if device.isMock {}
    }

    var chartXScaleDomain: ClosedRange<BSTimestamp> {
        guard dataArray.count >= 2 else {
            return 0 ... 1
        }
        let from = dataArray.first!.timestamp
        let to = dataArray.last!.timestamp
        guard to > from else {
            return 0 ... 1
        }
        return from ... to
    }

    enum DisplayMode: String, CaseIterable, Identifiable {
        var id: Self { self }

        case raw
        case metadata
    }

    @State private var displayMode: DisplayMode = .raw

    var body: some View {
        Picker("__Display Mode__", selection: $displayMode) {
            ForEach(DisplayMode.allCases) { displayMode in
                Text(displayMode.rawValue)
            }
        }
        Group {
            if displayMode == .raw {
                Chart {
                    ForEach(0 ..< dataArray.count, id: \.self) { index in
                        let data = dataArray[index]

                        ForEach(0 ..< data.pressure.sensors.count, id: \.self) { sensorIndex in
                            let sensorData = data.pressure.sensors[sensorIndex]

                            LineMark(
                                x: .value("Time", data.timestamp),
                                y: .value("Pressure", sensorData.normalizedValue)
                            )
                            .foregroundStyle(by: .value(sensorType.name, "\(sensorIndex + 1)"))
                        }
                    }
                }
            }
            else {
                Chart {
                    ForEach(0 ..< dataArray.count, id: \.self) { index in
                        let data = dataArray[index]

                        LineMark(
                            x: .value("Time", data.timestamp),
                            y: .value("Sum", data.pressure.normalizedSum)
                        )
                        .foregroundStyle(by: .value(sensorType.name, "Sum"))

                        LineMark(
                            x: .value("Time", data.timestamp),
                            y: .value("X", data.pressure.normalizedCenterOfPressure?.x ?? 0)
                        )
                        .foregroundStyle(by: .value(sensorType.name, "X"))

                        LineMark(
                            x: .value("Time", data.timestamp),
                            y: .value("Y", data.pressure.normalizedCenterOfPressure?.y ?? 0)
                        )
                        .foregroundStyle(by: .value(sensorType.name, "Y"))
                    }
                }
            }
        }
        .chartXAxis(.hidden)
        .chartYAxis(.hidden)
        .chartXScale(domain: chartXScaleDomain)
        .chartYScale(domain: chartYScaleDomain)
        .modify {
            if let publisher {
                $0.onReceive(publisher) { data in
                    dataArray.append(data)
                    trimDataPoints()
                }
            }
        }
        .onChange(of: maxDataPoints) { _, _ in
            trimDataPoints()
        }
    }
}

#Preview {
    List {
        PressureChart(device: .mock, maxDataPoints: .constant(20))
    }
    #if os(macOS)
    .frame(maxWidth: 350, minHeight: 300)
    #endif
}
