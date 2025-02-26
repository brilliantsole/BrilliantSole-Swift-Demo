//
//  Rotation3DChart.swift
//  BrilliantSoleSwiftDemo
//
//  Created by Zack Qattan on 2/25/25.
//

import BrilliantSole
import Charts
import Combine
import Spatial
import SwiftUI

struct Rotation3DChart: View {
    let device: BSDevice
    let sensorType: BSSensorType = .orientation
    @Binding var maxDataPoints: Int
    @State private var dataArray: [BSRotation3DData] = []
    private var chartYScaleDomain: ClosedRange<Float> = -Float.pi...Float.pi

    private var publisher: BSRotation3DPublisher? {
        device.orientationPublisher
    }

    func trimDataPoints() {
        if dataArray.count > maxDataPoints {
            dataArray.removeFirst(dataArray.count - maxDataPoints)
        }
    }

    @State private var eulerAngleOrder: EulerAngles.Order = .zxy

    var chartXScaleDomain: ClosedRange<Int> {
        guard !dataArray.isEmpty else {
            return 0...1
        }
        return 0...(dataArray.count - 1)

//        guard let from = dataArray.first?.timestamp,
//              let to = dataArray.last?.timestamp,
//              from < to
//        else {
//            return 0...1
//        }
//        return from...to
    }

    init(device: BSDevice, maxDataPoints: Binding<Int>) {
        self.device = device
        self._maxDataPoints = maxDataPoints
        if device.isMock {
            self._dataArray = .init(initialValue: generateDataArray(count: maxDataPoints.wrappedValue))
        }
    }

    var body: some View {
        Chart {
            ForEach(0 ..< dataArray.count, id: \.self) { index in
                let data = dataArray[index]
                let eulerAngles = data.rotation.eulerAngles(order: eulerAngleOrder)

                LineMark(
                    x: .value("Time", index),
                    y: .value("Pitch", eulerAngles.angles.x)
                )
                .foregroundStyle(by: .value(sensorType.name, "Pitch"))

                LineMark(
                    x: .value("Time", index),
                    y: .value("Yaw", eulerAngles.angles.y)
                )
                .foregroundStyle(by: .value(sensorType.name, "Yaw"))

                LineMark(
                    x: .value("Time", index),
                    y: .value("Roll", eulerAngles.angles.z)
                )
                .foregroundStyle(by: .value(sensorType.name, "Roll"))
            }
        }
        .chartXAxis(.hidden)
        .chartYAxis(.hidden)
        .chartXScale(domain: chartXScaleDomain)
        .chartYScale(domain: chartYScaleDomain)
        .modify {
            if let publisher {
                $0.onReceive(publisher) { data in
                    DispatchQueue.main.async {
                        dataArray.append(data)
                        trimDataPoints()
                    }
                }
            }
        }
        .onChange(of: maxDataPoints) { _, _ in
            trimDataPoints()
        }
        .onAppear {
            if false, device.isMock {
                var timestamp: BSTimestamp = 0
                Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
                    timestamp += 1
                    dataArray.append((rotation: randomRotation3D(), timestamp: timestamp))
                    trimDataPoints()
                }
            }
        }
    }
}

private func randomAngle() -> Angle2D {
    .radians(.random(in: -Double.pi...Double.pi))
}

private func randomRotation3D(radius: Double = 1) -> BSRotation3D {
    return .init(eulerAngles: .init(x: randomAngle(), y: randomAngle(), z: randomAngle(), order: .xyz))
}

private func generateDataArray(count: Int, startTimestamp: BSTimestamp = 0, sensorRate: BSSensorRate = ._20ms) -> [BSRotation3DData] {
    return (0 ..< count).map { i in
        (rotation: randomRotation3D(), timestamp: startTimestamp + BSTimestamp(i) * BSTimestamp(sensorRate.rawValue))
    }
}

#Preview {
    List {
        Rotation3DChart(device: .mock, maxDataPoints: .constant(50))
    }
    #if os(macOS)
    .frame(maxWidth: 350, minHeight: 300)
    #endif
}
