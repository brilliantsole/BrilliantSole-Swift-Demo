//
//  BarometerChart.swift
//  BrilliantSoleSwiftDemo
//
//  Created by Zack Qattan on 2/25/25.
//

import BrilliantSole
import Charts
import Combine
import SwiftUI

struct BarometerChart: View {
    let device: BSDevice
    let sensorType: BSSensorType = .barometer
    @Binding var maxDataPoints: Int
    @State private var dataArray: [BSBarometerData] = []
    private let chartYScaleDomain: ClosedRange<Float> = 0 ... 2000

    private var publisher: BSBarometerPublisher? {
        device.barometerPublisher
    }

    func trimDataPoints() {
        if dataArray.count > maxDataPoints {
            dataArray.removeFirst(dataArray.count - maxDataPoints)
        }
    }

    init(device: BSDevice, maxDataPoints: Binding<Int>) {
        self.device = device
        self._maxDataPoints = maxDataPoints
        if device.isMock {
            self._dataArray = .init(initialValue: generateDataArray(count: maxDataPoints.wrappedValue))
        }
    }

    var chartXScaleDomain: ClosedRange<Int> {
        return 0 ... maxDataPoints

//        guard !dataArray.isEmpty else {
//            return 0...1
//        }
//        return 0...(dataArray.count - 1)

//        guard let from = dataArray.first?.timestamp,
//              let to = dataArray.last?.timestamp,
//              from < to
//        else {
//            return 0...1
//        }
//        return from...to
    }

    var body: some View {
        Chart {
            ForEach(0 ..< dataArray.count, id: \.self) { index in
                let data = dataArray[index]
                LineMark(
                    x: .value("Time", index),
                    y: .value("Pressure", data.barometer)
                )
                .foregroundStyle(by: .value(sensorType.name, "Pressure"))
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
                    dataArray.append((barometer: .random(in: 0 ... 1000), timestamp: timestamp))
                    trimDataPoints()
                }
            }
        }
    }
}

private func generateDataArray(count: Int, startTimestamp: BSTimestamp = 0, sensorRate: BSSensorRate = ._20ms) -> [BSBarometerData] {
    return (0 ..< count).map { i in
        (barometer: .random(in: 0 ... 1000), timestamp: startTimestamp + BSTimestamp(i) * BSTimestamp(sensorRate.rawValue))
    }
}

#Preview {
    List {
        BarometerChart(device: .mock, maxDataPoints: .constant(20))
    }
    #if os(macOS)
    .frame(maxWidth: 350, minHeight: 300)
    #endif
}
