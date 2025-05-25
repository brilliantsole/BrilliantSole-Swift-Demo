//
//  MotionDataSection.swift
//  BrilliantSoleSwiftDemo
//
//  Created by Zack Qattan on 2/27/25.
//

import BrilliantSole
import Combine
import SwiftUI

struct MotionDataSection: View {
    let device: BSDevice

    private let dataLayout = isWatch ? AnyLayout(VStackLayout(alignment: .leading)) : AnyLayout(HStackLayout())

    @ViewBuilder
    private func timestampView(timestamp: BSTimestamp) -> some View {
        Text("[\(timestamp.timestampString)]")
    }

    @State private var accelerationData: BSVector3DData?
    @State private var linearAccelerationData: BSVector3DData?
    @State private var gravityData: BSVector3DData?
    @State private var gyroscopeData: BSVector3DData?
    @State private var magnetometerData: BSVector3DData?

    private func getVectorData(sensorType: BSSensorType) -> BSVector3DData? {
        switch sensorType {
        case .acceleration:
            accelerationData
        case .gravity:
            gravityData
        case .linearAcceleration:
            linearAccelerationData
        case .gyroscope:
            gyroscopeData
        case .magnetometer:
            magnetometerData
        default:
            nil
        }
    }

    @ViewBuilder
    private func vectorView(sensorType: BSSensorType) -> some View {
        if let vectorData = getVectorData(sensorType: sensorType) {
            dataLayout {
                timestampView(timestamp: vectorData.timestamp)
                Text(vectorData.vector.string)
            }
        }
    }

    @State private var gameRotationData: BSQuaternionData?
    @State private var rotationData: BSQuaternionData?

    private func getQuaternionData(sensorType: BSSensorType) -> BSQuaternionData? {
        switch sensorType {
        case .gameRotation:
            gameRotationData
        case .rotation:
            rotationData
        default:
            nil
        }
    }

    @ViewBuilder
    private func quaternionView(sensorType: BSSensorType) -> some View {
        if let quaternionData = getQuaternionData(sensorType: sensorType) {
            dataLayout {
                timestampView(timestamp: quaternionData.timestamp)
                Text(quaternionData.quaternion.string)
            }

            dataLayout {
                Text("__Euler Angles__:")
                let eulerAngles = BSRotation3D(quaternion: quaternionData.quaternion)
                Text(eulerAngles.string)
            }
        }
    }

    @State private var orientationData: BSRotation3DData?

    @ViewBuilder
    private func rotationView(sensorType: BSSensorType) -> some View {
        if let orientationData {
            dataLayout {
                timestampView(timestamp: orientationData.timestamp)
                Text(orientationData.rotation.string)
            }
        }
    }

    @State private var deviceOrientationData: BSDeviceOrientationData?

    @ViewBuilder
    private func deviceOrientationView() -> some View {
        if let deviceOrientationData {
            dataLayout {
                timestampView(timestamp: deviceOrientationData.timestamp)
                Text(deviceOrientationData.deviceOrientation.name)
            }
        }
    }

    @State private var stepCountData: BSStepCountData?

    @ViewBuilder
    private func stepCountView() -> some View {
        if let stepCountData {
            dataLayout {
                timestampView(timestamp: stepCountData.timestamp)
                Text("\(stepCountData.stepCount)")
            }
        }
    }

    @State private var stepDetectionData: BSVoidTimestampData?
    @State private var tapDetectionData: BSVoidTimestampData?

    private func getVoidTimestampData(sensorType: BSSensorType) -> BSVoidTimestampData? {
        switch sensorType {
        case .stepDetection:
            stepDetectionData
        case .tapDetection:
            tapDetectionData
        default:
            nil
        }
    }

    @ViewBuilder
    private func voidTimestampView(sensorType: BSSensorType) -> some View {
        if let voidTimestampData = getVoidTimestampData(sensorType: sensorType) {
            dataLayout {
                timestampView(timestamp: voidTimestampData)
            }
        }
    }

    @State private var activityData: BSActivityData?

    @ViewBuilder
    private func activityView() -> some View {
        if let activityData {
            dataLayout {
                timestampView(timestamp: activityData.timestamp)
                Text("\(activityData.activityFlags.string)")
            }
        }
    }

    @ViewBuilder func dataView(sensorType: BSSensorType) -> some View {
        if sensorType.dataType == BSVector3D.self {
            vectorView(sensorType: sensorType)
        }
        else if sensorType.dataType == BSQuaternion.self {
            quaternionView(sensorType: sensorType)
        }
        else if sensorType.dataType == BSRotation3D.self {
            rotationView(sensorType: sensorType)
        }
        else if sensorType.dataType == BSDeviceOrientation.self {
            deviceOrientationView()
        }
        else if sensorType.dataType == BSStepCount.self {
            stepCountView()
        }
        else if sensorType.dataType == BSActivityFlags.self {
            activityView()
        }
        else if sensorType.dataType == Void.self {
            voidTimestampView(sensorType: sensorType)
        }
        else {
            Text("uncaught dataType \(String(describing: sensorType.dataType))")
        }
    }

    var body: some View {
        ForEach(BSSensorType.allCases.filter { $0.isMotion && device.containsSensorType($0) }) { sensorType in
            Section {
                SensorRatePicker(device: device, sensorType: sensorType)
                dataView(sensorType: sensorType)
            } header: {
                Text(sensorType.name.capitalized)
                    .font(.headline)
            }
        }
        .onReceive(device.accelerationPublisher) {
            accelerationData = $0
        }
        .onReceive(device.gravityPublisher) {
            gravityData = $0
        }
        .onReceive(device.linearAccelerationPublisher) {
            linearAccelerationData = $0
        }
        .onReceive(device.gyroscopePublisher) {
            gyroscopeData = $0
        }
        .onReceive(device.magnetometerPublisher) {
            magnetometerData = $0
        }
        .onReceive(device.gameRotationPublisher) {
            gameRotationData = $0
        }
        .onReceive(device.rotationPublisher) {
            rotationData = $0
        }
        .onReceive(device.orientationPublisher) {
            orientationData = $0
        }
        .onReceive(device.activityPublisher) {
            activityData = $0
        }
        .onReceive(device.deviceOrientationPublisher) {
            deviceOrientationData = $0
        }
        .onReceive(device.stepCountPublisher) {
            stepCountData = $0
        }
        .onReceive(device.stepDetectionPublisher) {
            stepDetectionData = $0
        }
        .onReceive(device.tapDetectionPublisher) {
            tapDetectionData = $0
        }
    }
}

#Preview {
    List {
        MotionDataSection(device: .mock)
    }
    #if os(macOS)
    .frame(maxWidth: 350, minHeight: 300)
    #endif
}
