//
//  Example.swift
//  BrilliantSoleSwiftDemo
//
//  Created by Zack Qattan on 2/18/25.
//

import BrilliantSole
import SwiftUI
import UkatonMacros

@EnumName
enum Example: CaseIterable, Identifiable {
    public var id: Self { self }

    case sensorData
    case motion
    case pressure
    case centerOfPressure
    case vibration
    case tflite
    case graph
    case firmware

    var requiresPressure: Bool {
        switch self {
        case .pressure, .centerOfPressure:
            true
        default:
            false
        }
    }

    var requiresFirmware: Bool {
        switch self {
        case .firmware:
            true
        default:
            false
        }
    }

    var requiresVibration: Bool {
        switch self {
        case .vibration:
            true
        default:
            false
        }
    }

    var requiresTflite: Bool {
        switch self {
        case .tflite:
            true
        default:
            false
        }
    }

    var requiresFileTransfer: Bool {
        switch self {
        default:
            false
        }
    }

    func worksWith(device: BSDevice) -> Bool {
        guard !self.requiresFirmware || device.canUpgradeFirmware else { return false }
        guard !self.requiresPressure || (device.sensorTypes.contains(.pressure) && device.isInsole) else { return false }
        guard !self.requiresTflite || device.isTfliteAvailable else { return false }
        // guard !self.requiresVibration || !device.vibrationLocations.isEmpty else { return false }
        return true
    }

    @ViewBuilder func view(device: BSDevice) -> some View {
        switch self {
        case .sensorData:
            SensorDataExample(device: device)
        case .motion:
            MotionExample(device: device)
        case .pressure:
            PressureExample(device: device)
        case .centerOfPressure:
            CenterOfPressureExample(centerOfPressureProvider: device)
        case .vibration:
            VibrationExample(vibratable: device)
        case .tflite:
            TfliteExample(device: device)
        case .graph:
            GraphExample(device: device)
        case .firmware:
            FirmwareExample(device: device)
        }
    }
}
