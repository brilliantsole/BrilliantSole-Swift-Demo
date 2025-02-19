//
//  RotationModePicker.swift
//  BrilliantSoleSwiftDemo
//
//  Created by Zack Qattan on 2/18/25.
//

import BrilliantSole
import SwiftUI
import UkatonMacros

struct RotationModePicker: View {
    let sensorDataConfigurable: BSSensorConfigurable

    @EnumName
    enum RotationMode: CaseIterable, Identifiable {
        var id: String { name }

        case none
        case gyroscope
        case rotation
        case gameRotation
        case orientation

        var sensorType: BSSensorType? {
            return switch self {
            case .none:
                nil
            case .gyroscope:
                .gyroscope
            case .gameRotation:
                .gameRotation
            case .orientation:
                .orientation
            case .rotation:
                .rotation
            }
        }

        var showSensorType: Bool {
            return switch self {
            case .none, .gyroscope, .rotation, .orientation, .gameRotation:
                true
            default:
                false
            }
        }
    }

    @State private var rotationMode: RotationMode = .none

    var body: some View {
        Picker(selection: $rotationMode, label: EmptyView()) {
            ForEach(RotationMode.allCases) { rotationMode in
                if rotationMode.showSensorType {
                    Text(rotationMode.name)
                        .tag(rotationMode)
                }
            }
        }
        // .pickerStyle(.segmented)
        .onChange(of: rotationMode) { _, newRotationMode in
            var sensorConfiguration: BSSensorConfiguration = .init()
            for rotationMode in RotationMode.allCases {
                guard let sensorType = rotationMode.sensorType else { continue }

                sensorConfiguration[sensorType] = ._0ms
            }
            if let sensorType = newRotationMode.sensorType {
                sensorConfiguration[sensorType] = ._20ms
            }
            self.rotationMode = newRotationMode
            sensorDataConfigurable.setSensorConfiguration(sensorConfiguration)
        }
    }
}

#Preview {
    NavigationStack {
        RotationModePicker(sensorDataConfigurable: BSDevice.mock)
    }
    #if os(macOS)
    .frame(maxWidth: 300)
    #endif
}
