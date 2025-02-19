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

    var requiresPressure: Bool {
        switch self {
        case .pressure, .centerOfPressure:
            true
        default:
            false
        }
    }

    func worksWith(device: BSDevice) -> Bool {
        guard !self.requiresPressure || device.deviceType.isInsole else { return false }
        return true
    }

    @ViewBuilder func view(device: BSDevice) -> some View {
        switch self {
        case .sensorData:
            MotionExample(device: device)
        case .motion:
            MotionExample(device: device)
        case .pressure:
            MotionExample(device: device)
        case .centerOfPressure:
            MotionExample(device: device)
        case .vibration:
            MotionExample(device: device)
        }
    }
}
