//
//  DeviceMetadata.swift
//  BrilliantSoleSwiftDemo
//
//  Created by Zack Qattan on 2/28/25.
//

import BrilliantSole

struct DiscoveredDeviceMetadata: AppGroupDeviceMetadata {
    static let none: Self = .init(id: "", name: "", deviceType: .leftInsole, connectionType: nil, connectionStatus: .notConnected)
    var isNone: Bool { id == "" }

    let id: String
    let name: String
    let deviceType: BSDeviceType
    let connectionType: BSConnectionType?
    let connectionStatus: BSConnectionStatus
}

typealias RawDiscoveredDeviceMetadata = [String: String]
