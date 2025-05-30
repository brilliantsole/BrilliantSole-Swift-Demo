//
//  DeviceMetadataManager.swift
//  BrilliantSoleSwiftDemo
//
//  Created by Zack Qattan on 2/28/25.
//

import BrilliantSole
import Combine
import Foundation
import OSLog
import SwiftUI
import UkatonMacros
import WidgetKit

@StaticLogger(disabled: true)
@Singleton
class DeviceMetadataManager {
    private let defaults: UserDefaults? = getUserDefaults("devices")

    var ids: [String] {
        defaults?.object(forKey: "deviceIds") as? [String] ?? []
    }

    var isScanning: Bool {
        defaults?.object(forKey: "isScanning") as? Bool ?? false
    }

    func getMetadata(id: String) -> DeviceMetadata? {
        guard let value = defaults?.object(forKey: "device-\(id)") as? RawDeviceMetadata,
              let name = value["name"],
              let deviceTypeName = value["deviceType"],
              let deviceType: BSDeviceType = .init(name: deviceTypeName),
              let batteryLevelString = value["batteryLevel"],
              let batteryLevel: BSBatteryLevel = .init(batteryLevelString),
              let isChargingString = value["isCharging"],
              let connectionStatusString = value["connectionStatus"],
              let connectionStatus: BSConnectionStatus = .init(name: connectionStatusString)
        else {
            return nil
        }

        let isCharging = isChargingString == "true"

        var connectionType: BSConnectionType?
        if let connectionTypeString = value["connectionType"] {
            connectionType = .init(name: connectionTypeString)
        }

        return .init(id: id, name: name, deviceType: deviceType, batteryLevel: batteryLevel, isCharging: isCharging, connectionType: connectionType, connectionStatus: connectionStatus)
    }

    func getMetadata(index: Int) -> DeviceMetadata? {
        guard index < ids.count else { return nil }
        return getMetadata(id: ids[index])
    }

    private func key(for device: BSDevice) -> String {
        "device-\(device.connectionId)"
    }

    private var cancellables: Set<AnyCancellable> = .init()
    private var devicesCancellables: [String: Set<AnyCancellable>] = .init()
    private func updateDeviceMetadata(for device: BSDevice) {
        var rawDeviceMetadata: RawDeviceMetadata = [
            "name": device.name,
            "deviceType": device.deviceType.name,
            "batteryLevel": .init(device.batteryLevel),
            "isCharging": device.isBatteryCharging ? "true" : "false",
            "connectionStatus": device.connectionStatus.name
        ]
        if let connectionType = device.connectionType {
            rawDeviceMetadata["connectionType"] = connectionType.name
        }
        defaults?.set(rawDeviceMetadata, forKey: key(for: device))
        let _key = key(for: device)
        logger?.debug("set value for key \(_key, privacy: .public): \(rawDeviceMetadata, privacy: .public)")
    }

    private var isListeningForUpdates: Bool = false
    func listenForUpdates() {
        guard !isListeningForUpdates else { return }
        isListeningForUpdates = true

        logger?.debug("listening for DeviceMetadata updates")

        BSDeviceManager.availableDevicePublisher.sink(receiveValue: { [self] device in
            if devicesCancellables[device.connectionId] == nil {
                devicesCancellables[device.connectionId] = .init()
            }

            updateDeviceMetadata(for: device)

            device.batteryLevelPublisher.dropFirst().sink(receiveValue: { [self, device] _ in
                updateDeviceMetadata(for: device)
                reloadTimelines()
            }).store(in: &devicesCancellables[device.connectionId]!)

            device.connectionStatusPublisher.dropFirst().sink(receiveValue: { [self, device] _ in
                updateDeviceMetadata(for: device)
                reloadTimelines()
            }).store(in: &devicesCancellables[device.connectionId]!)

            device.isBatteryChargingPublisher.dropFirst().sink(receiveValue: { [self, device] _ in
                updateDeviceMetadata(for: device)
                reloadTimelines()
            }).store(in: &devicesCancellables[device.connectionId]!)

            let newIds = BSDeviceManager.availableDevices.map { $0.connectionId }
            defaults?.set(newIds, forKey: "deviceIds")
            logger?.debug("device added - updating deviceIds to \(newIds)")

            reloadTimelines()
        }).store(in: &cancellables)

        BSDeviceManager.unavailableDevicePublisher.sink(receiveValue: { [self] device in
            defaults?.removeObject(forKey: key(for: device))
            let _key = key(for: device)
            logger?.debug("removed value for key \(_key)")

            let newIds = BSDeviceManager.availableDevices.map { $0.connectionId }
            defaults?.set(newIds, forKey: "deviceIds")
            logger?.debug("device removed - updating deviceIds to \(newIds)")

            devicesCancellables.removeValue(forKey: device.connectionId)

            reloadTimelines()
        }).store(in: &cancellables)
    }

    func reloadTimelines() {
        logger?.debug("reloading timelines")
        // WidgetCenter.shared.reloadTimelines(ofKind: "com.brilliantsole.demo.battery-level")
        WidgetCenter.shared.reloadAllTimelines()
    }

    func clear() {
        for id in ids {
            defaults?.removeObject(forKey: "device-\(id)")
        }
        defaults?.removeObject(forKey: "deviceIds")
        WidgetCenter.shared.reloadAllTimelines()
    }
}
