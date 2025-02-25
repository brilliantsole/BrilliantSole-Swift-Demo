//
//  TfliteModelSettings.swift
//  BrilliantSoleSwiftDemo
//
//  Created by Zack Qattan on 2/24/25.
//

import BrilliantSole
import Combine
import SwiftUI

struct TfliteModelSettings: View {
    let device: BSDevice
    @Binding var selectedModelMode: TfliteModelMode
    @EnvironmentObject var tfliteFileState: TfliteFileState

    @State private var isTfliteInferencingEnabled = false

    var canEdit: Bool {
        !isWatch && !isTv && selectedModelMode == .custom
    }

    var body: some View {
        Section {
            if canEdit {
                TextField("Model Name", text: $tfliteFileState.tfliteFile.modelName)
                    .autocorrectionDisabled()
                    .disabled(isTfliteInferencingEnabled)
            } else {
                Text("__Model Name:__ \(tapStompKickTfliteModel.modelName)")
            }

            if canEdit {
                Picker("__Task__", selection: $tfliteFileState.tfliteFile.task) {
                    ForEach(BSTfliteTask.allCases) { task in
                        Text(task.name)
                    }
                }
                .disabled(isTfliteInferencingEnabled)
            } else {
                Text("__Task:__ \(tapStompKickTfliteModel.task.name)")
            }

            if canEdit {
                Picker("__Sensor Rate__", selection: $tfliteFileState.tfliteFile.sensorRate) {
                    ForEach(BSSensorRate.allCases.filter { $0.rawValue > 0 }) { sensorRate in
                        Text(sensorRate.name)
                    }
                }
                .disabled(isTfliteInferencingEnabled)
            } else {
                Text("__Sensor Rate:__ \(tapStompKickTfliteModel.sensorRate.name)")
            }

            if canEdit {
                ForEach(BSTfliteSensorType.allCases) { sensorType in
                    Toggle(sensorType.name, isOn: Binding(
                        get: { tfliteFileState.tfliteFile.sensorTypes.contains(sensorType) },
                        set: { isSelected in
                            if isSelected {
                                tfliteFileState.tfliteFile.sensorTypes.insert(sensorType)
                            } else {
                                tfliteFileState.tfliteFile.sensorTypes.remove(sensorType)
                            }
                        }
                    ))
                }
                .disabled(isTfliteInferencingEnabled)
            } else {
                Text("__Sensor Types:__ \(tapStompKickTfliteModel.sensorTypes.map(\.name).joined(separator: ", "))")
            }
        } header: {
            Text("Model Settings")
        }
        .onReceive(device.tfliteInferencingEnabledPublisher) { isTfliteInferencingEnabled = $0 }
    }
}

#Preview {
    @Previewable @StateObject var tfliteFileState = TfliteFileState()
    @Previewable @State var selectedModelMode: TfliteModelMode = .tapStompKick

    List {
        TfliteModelSettings(device: .mock, selectedModelMode: $selectedModelMode)
    }
    #if os(macOS)
    .frame(maxWidth: 350, minHeight: 300)
    #endif
}
