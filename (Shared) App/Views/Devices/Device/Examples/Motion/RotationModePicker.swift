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
    let sensorConfigurable: BSSensorConfigurable

    @EnumName
    enum RotationMode: CaseIterable, Identifiable {
        var id: String { name }

        case noRotation
        case gyroscope
        case rotation
        case gameRotation
        case orientation

        var sensorType: BSSensorType? {
            return switch self {
            case .noRotation:
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

        func showSensorType(sensorTypes: [BSSensorType]) -> Bool {
            guard let sensorType else {
                return true
            }
            guard sensorTypes.contains(sensorType) else {
                return false
            }
            return switch self {
            case .noRotation, .gyroscope, .rotation, .gameRotation, .orientation:
                true
            default:
                false
            }
        }
    }

    @State private var rotationMode: RotationMode = .noRotation

    var body: some View {
        HStack {
            Picker(selection: $rotationMode, label: EmptyView()) {
                ForEach(
                    RotationMode.allCases
                        .filter { $0.showSensorType(sensorTypes: sensorConfigurable.sensorTypes) }
                        .prefix(3),
                    id: \.self
                ) { rotationMode in
                    Text(rotationMode.name)
                        .tag(rotationMode)
                }
            }
            #if os(tvOS)
            .pickerStyle(.menu)
            #else
            .pickerStyle(.segmented)
            #endif
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
                sensorConfigurable.setSensorConfiguration(sensorConfiguration)
            }
        }
    }
}

#Preview {
    NavigationStack {
        RotationModePicker(sensorConfigurable: BSDevice.mock)
    }
    #if os(macOS)
    .frame(maxWidth: 300)
    #endif
}
