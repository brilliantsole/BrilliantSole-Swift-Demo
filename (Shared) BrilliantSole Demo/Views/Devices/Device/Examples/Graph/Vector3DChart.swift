//
//  Vector3DChart.swift
//  BrilliantSoleSwiftDemo
//
//  Created by Zack Qattan on 2/25/25.
//

import BrilliantSole
import Charts
import Combine
import SwiftUI

struct Vector3DChart: View {
    let device: BSDevice
    let sensorType: BSSensorType
    @Binding var maxDataPoints: Int
    @State private var dataArray: [BSVector3DData] = []

    private var publisher: BSVector3DPublisher? {
        device.getVectorPublisher(for: sensorType)
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
            // self._dataArray = .init(initialValue: generateDataArray(count: maxDataPoints.wrappedValue))
        }
    }

    var chartXScaleDomain: ClosedRange<BSTimestamp> {
        guard dataArray.count >= 2 else {
            return 0...1
        }
        let from = dataArray.first!.timestamp
        let to = dataArray.last!.timestamp
        guard to > from else {
            return 0...1
        }
        return from...to
    }

    var body: some View {
        Text("dataArray \(dataArray.count)")
        Chart {
            ForEach(0 ..< dataArray.count, id: \.self) { index in
                let data = dataArray[index]
                LineMark(
                    x: .value("Time", data.timestamp),
                    y: .value("X", data.vector.x)
                )
                .foregroundStyle(.red)
                .foregroundStyle(by: .value(sensorType.name, "X"))

                LineMark(
                    x: .value("Time", data.timestamp),
                    y: .value("Y", data.vector.y)
                )
                .foregroundStyle(.green)
                .foregroundStyle(by: .value(sensorType.name, "Y"))

                LineMark(
                    x: .value("Time", data.timestamp),
                    y: .value("Z", data.vector.z)
                )
                .foregroundStyle(.blue)
                .foregroundStyle(by: .value(sensorType.name, "Z"))
            }
        }
        .chartXAxis(.hidden)
        .chartYAxis(.hidden)
        .chartXScale(domain: chartXScaleDomain)
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
        .onAppear {
            if device.isMock {
                var timestamp: BSTimestamp = 0
                Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
                    timestamp += 1
                    dataArray.append((vector: randomVector3D(), timestamp: timestamp))
                    trimDataPoints()
                }
            }
        }
    }
}

private func randomVector3D(radius: Double = 1) -> BSVector3D {
    return .init(
        x: .random(in: -radius...radius),
        y: .random(in: -radius...radius),
        z: .random(in: -radius...radius)
    )
}

private func generateDataArray(count: Int, startTimestamp: BSTimestamp = 0, sensorRate: BSSensorRate = ._20ms) -> [BSVector3DData] {
    return (0 ..< count).map { i in
        (vector: randomVector3D(), timestamp: startTimestamp + BSTimestamp(i) * BSTimestamp(sensorRate.rawValue))
    }
}

#Preview {
    List {
        Vector3DChart(device: .mock, sensorType: .linearAcceleration, maxDataPoints: .constant(100))
    }
    #if os(macOS)
    .frame(maxWidth: 350, minHeight: 300)
    #endif
}
