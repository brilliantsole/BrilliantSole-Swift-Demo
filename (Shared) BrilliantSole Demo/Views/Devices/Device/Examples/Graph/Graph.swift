//
//  Graph.swift
//  BrilliantSoleSwiftDemo
//
//  Created by Zack Qattan on 2/25/25.
//

import BrilliantSole
import Combine
import SwiftUI

struct Graph: View {
    let device: BSDevice
    let sensorType: BSSensorType
    @Binding var maxDataPoints: Int

    @State private var sensorRate: BSSensorRate = ._0ms

    @ViewBuilder func chartView(sensorType: BSSensorType) -> some View {
        if sensorType.dataType == BSVector3D.self {
            Vector3DChart(device: device, sensorType: sensorType, maxDataPoints: $maxDataPoints)
        }
        else if sensorType.dataType == BSQuaternion.self {
            QuaternionChart(device: device, sensorType: sensorType, maxDataPoints: $maxDataPoints)
        }
    }

    var body: some View {
        Section {
            Picker("__Sensor Rate__", selection: $sensorRate) {
                ForEach(BSSensorRate.allCases) { sensorRate in
                    Text(sensorRate.name)
                }
            }
            .onChange(of: sensorRate) { _, sensorRate in
                device.setSensorRate(sensorType: sensorType, sensorRate: sensorRate)
            }
            chartView(sensorType: sensorType)
        } header: {
            Text(sensorType.name.capitalized)
        }
        .onReceive(device.sensorConfigurationPublisher) { configuration in
            sensorRate = configuration[sensorType] ?? ._0ms
        }
    }
}

#Preview {
    List {
        Graph(device: .mock, sensorType: .linearAcceleration, maxDataPoints: .constant(100))
    }
    #if os(macOS)
    .frame(maxWidth: 350, minHeight: 300)
    #endif
}
