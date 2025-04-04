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

    @ViewBuilder func chartView(sensorType: BSSensorType) -> some View {
        if sensorType.dataType == BSPressureDataTuple.self {
            PressureChart(device: device, maxDataPoints: $maxDataPoints)
        }
        else if sensorType.dataType == BSVector3D.self {
            Vector3DChart(device: device, sensorType: sensorType, maxDataPoints: $maxDataPoints)
        }
        else if sensorType.dataType == BSQuaternion.self {
            QuaternionChart(device: device, sensorType: sensorType, maxDataPoints: $maxDataPoints)
        }
        else if sensorType.dataType == BSRotation3D.self {
            Rotation3DChart(device: device, maxDataPoints: $maxDataPoints)
        }
        else if sensorType.dataType == BSBarometer.self {
            BarometerChart(device: device, maxDataPoints: $maxDataPoints)
        }
    }

    var body: some View {
        Section {
            if isWatch {
                SensorRateToggle(device: device, sensorType: sensorType, sensorRate: ._20ms)
            }
            else {
                SensorRatePicker(device: device, sensorType: sensorType)
            }
            chartView(sensorType: sensorType)
        } header: {
            Text(sensorType.name.capitalized)
        }
    }
}

#Preview {
    List {
        Graph(device: .mock, sensorType: .linearAcceleration, maxDataPoints: .constant(50))
    }
    #if os(macOS)
    .frame(maxWidth: 350, minHeight: 300)
    #endif
}
