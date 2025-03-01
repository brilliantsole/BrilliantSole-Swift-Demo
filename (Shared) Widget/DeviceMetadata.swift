//
//  DeviceMetadata.swift
//  BrilliantSoleSwiftDemo
//
//  Created by Zack Qattan on 2/28/25.
//

import BrilliantSole

struct DeviceMetadata: AppGroupDeviceMetadata {
    static let none: Self = .init(id: "", name: "", deviceType: .leftInsole, batteryLevel: 0, isCharging: false, connectionType: nil, connectionStatus: .notConnected)
    var isNone: Bool { id == "" }

    let id: String
    let name: String
    let deviceType: BSDeviceType
    let batteryLevel: BSBatteryLevel
    let isCharging: Bool
    let connectionType: BSConnectionType?
    let connectionStatus: BSConnectionStatus
}

typealias RawDeviceMetadata = [String: String]
