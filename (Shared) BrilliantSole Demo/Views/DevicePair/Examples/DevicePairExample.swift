//
//  DevicePairExample.swift
//  BrilliantSoleSwiftDemo
//
//  Created by Zack Qattan on 2/18/25.
//

import BrilliantSole
import SwiftUI
import UkatonMacros

@EnumName
enum DevicePairExample: CaseIterable, Identifiable {
    public var id: Self { self }

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

    func worksWith(devicePair: BSDevicePair) -> Bool {
        guard self != .motion || !isWatch else { return false }
        return true
    }

    @ViewBuilder func view(devicePair: BSDevicePair) -> some View {
        switch self {
        case .motion:
            DevicePairMotionExample(devicePair: devicePair)
        case .pressure:
            DevicePairPressureExample(devicePair: devicePair)
        case .centerOfPressure:
            CenterOfPressureExample(centerOfPressureProvider: devicePair)
        case .vibration:
            VibrationExample(vibratable: devicePair)
        }
    }
}
