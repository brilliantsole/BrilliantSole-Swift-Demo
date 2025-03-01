//
//  AppGroupDeviceMetadata.swift
//  BrilliantSoleSwiftDemo
//
//  Created by Zack Qattan on 2/28/25.
//

import BrilliantSole

protocol AppGroupDeviceMetadata: Identifiable {
    var id: String { get }
    var name: String { get }
    var deviceType: BSDeviceType { get }
    var connectionStatus: BSConnectionStatus { get }
    var connectionType: BSConnectionType? { get }
}

extension AppGroupDeviceMetadata {
    var isConnected: Bool { connectionStatus == .connected }
}
