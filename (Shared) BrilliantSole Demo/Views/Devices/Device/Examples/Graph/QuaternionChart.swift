//
//  QuaternionChart.swift
//  BrilliantSoleSwiftDemo
//
//  Created by Zack Qattan on 2/25/25.
//

import BrilliantSole
import Charts
import Combine
import simd
import Spatial
import SwiftUI

struct QuaternionChart: View {
    let device: BSDevice
    let sensorType: BSSensorType
    @Binding var maxDataPoints: Int
    @State private var dataArray: [BSQuaternionData] = []

    enum DisplayMode {
        case quaternion
        case eulerAngles
    }

    @State private var displayMode: DisplayMode = .eulerAngles
    @State private var eulerAngleOrder: EulerAngles.Order = .xyz

    private var publisher: BSQuaternionPublisher? {
        device.getQuaternionPublisher(for: sensorType)
    }

    func trimDataPoints() {
        if dataArray.count > maxDataPoints {
            dataArray.removeFirst(dataArray.count - maxDataPoints)
        }
    }

    init(device: BSDevice, sensorType: BSSensorType, maxDataPoints: Binding<Int>) {
        self.device = device
        self.sensorType = sensorType
        self._maxDataPoints = maxDataPoints
        if device.isMock {
            self._dataArray = .init(initialValue: generateDataArray(count: maxDataPoints.wrappedValue))
        }
    }

    var body: some View {
        Group {
            if displayMode == .quaternion {
                Chart {
                    ForEach(0 ..< dataArray.count, id: \.self) { index in
                        let data = dataArray[index]
                        LineMark(
                            x: .value("Time", data.timestamp),
                            y: .value("X", data.quaternion.vector.x)
                        )
                        .foregroundStyle(.red)
                        .foregroundStyle(by: .value(sensorType.name, "X"))

                        LineMark(
                            x: .value("Time", data.timestamp),
                            y: .value("Y", data.quaternion.vector.y)
                        )
                        .foregroundStyle(.green)
                        .foregroundStyle(by: .value(sensorType.name, "Y"))

                        LineMark(
                            x: .value("Time", data.timestamp),
                            y: .value("Z", data.quaternion.vector.z)
                        )
                        .foregroundStyle(.blue)
                        .foregroundStyle(by: .value(sensorType.name, "Z"))

                        LineMark(
                            x: .value("Time", data.timestamp),
                            y: .value("W", data.quaternion.vector.w)
                        )
                        .foregroundStyle(.purple)
                        .foregroundStyle(by: .value(sensorType.name, "W"))
                    }
                }
            }
            else {
                Chart {
                    ForEach(0 ..< dataArray.count, id: \.self) { index in
                        let data = dataArray[index]

                        let eulerAngles = Rotation3D(quaternion: data.quaternion).eulerAngles(order: eulerAngleOrder)

                        LineMark(
                            x: .value("Time", data.timestamp),
                            y: .value("Pitch", eulerAngles.angles.x)
                        )
                        .foregroundStyle(.red)
                        .foregroundStyle(by: .value(sensorType.name, "Pitch"))

                        LineMark(
                            x: .value("Time", data.timestamp),
                            y: .value("Yaw", eulerAngles.angles.y)
                        )
                        .foregroundStyle(.green)
                        .foregroundStyle(by: .value(sensorType.name, "Yaw"))

                        LineMark(
                            x: .value("Time", data.timestamp),
                            y: .value("Roll", eulerAngles.angles.z)
                        )
                        .foregroundStyle(.blue)
                        .foregroundStyle(by: .value(sensorType.name, "Roll"))
                    }
                }
            }
        }
        .chartXAxis(.hidden)
        .chartYAxis(.hidden)
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

private func randomQuaternion() -> BSQuaternion {
    let angle = Double.random(in: 0...(2 * .pi))
    let axis = simd_normalize(simd_double3(
        Double.random(in: -1...1),
        Double.random(in: -1...1),
        Double.random(in: -1...1)
    ))

    return .init(angle: angle, axis: axis)
}

private func generateDataArray(count: Int, startTimestamp: BSTimestamp = 0, sensorRate: BSSensorRate = ._20ms) -> [BSQuaternionData] {
    return (0 ..< count).map { i in
        (quaternion: randomQuaternion(), timestamp: startTimestamp + BSTimestamp(i) * BSTimestamp(sensorRate.rawValue))
    }
}

#Preview {
    List {
        QuaternionChart(device: .mock, sensorType: .linearAcceleration, maxDataPoints: .constant(20))
    }
    #if os(macOS)
    .frame(maxWidth: 350, minHeight: 300)
    #endif
}
