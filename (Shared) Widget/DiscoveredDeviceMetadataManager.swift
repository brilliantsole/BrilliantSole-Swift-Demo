//
//  DiscoveredDeviceMetadataManager.swift
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

@StaticLogger
@Singleton()
class DiscoveredDeviceMetadataManager {
    private let defaults: UserDefaults = .init(suiteName: "group.com.brilliantsole.discovered-devices")!

    var scanner: BSScanner {
        BSBleScanner.shared
    }

    var ids: [String] {
        defaults.object(forKey: "deviceIds") as? [String] ?? []
    }

    var isScanning: Bool {
        defaults.object(forKey: "isScanning") as? Bool ?? false
    }

    func getInformation(id: String) -> DiscoveredDeviceMetadata? {
        guard let value = defaults.object(forKey: "device-\(id)") as? RawDiscoveredDeviceMetadata,
              let name = value["name"],
              let deviceTypeName = value["deviceType"],
              let deviceType: BSDeviceType = .init(name: deviceTypeName),
              let connectionStatusString = value["connectionStatus"],
              let connectionStatus: BSConnectionStatus = .init(name: connectionStatusString)
        else {
            return nil
        }

        var connectionType: BSConnectionType?
        if let connectionTypeString = value["connectionType"] {
            connectionType = .init(name: connectionTypeString)
        }

        return .init(id: id, name: name, deviceType: deviceType, connectionType: connectionType, connectionStatus: connectionStatus)
    }

    func getInformation(index: Int) -> DiscoveredDeviceMetadata? {
        guard index < ids.count else { return nil }
        return getInformation(id: ids[index])
    }

    private func key(for discoveredDevice: BSDiscoveredDevice) -> String {
        key(id: discoveredDevice.id)
    }

    private func key(id: String) -> String {
        "device-\(id)"
    }

    private var cancellables: Set<AnyCancellable> = .init()
    private var devicesCancellables: [String: Set<AnyCancellable>] = .init()
    private func updateDeviceInformation(for discoveredDevice: BSDiscoveredDevice) -> Bool {
        var shouldUpdateDeviceMetadata = false
        if let discoveredDeviceInformation = getInformation(id: discoveredDevice.id), let device = discoveredDevice.device {
            if discoveredDevice.name != discoveredDeviceInformation.name ||
                discoveredDevice.deviceType != discoveredDeviceInformation.deviceType ||
                device.isConnected != discoveredDeviceInformation.isConnected ||
                device.connectionStatus != discoveredDeviceInformation.connectionStatus ||
                device.connectionType != discoveredDeviceInformation.connectionType
            {
                shouldUpdateDeviceMetadata = true
            }
        }
        else {
            shouldUpdateDeviceMetadata = true
        }

        if shouldUpdateDeviceMetadata, let device = discoveredDevice.device {
            var rawDiscoveredDeviceMetadata: RawDiscoveredDeviceMetadata = [
                "name": discoveredDevice.name,
                "deviceType": discoveredDevice.deviceType.name,
                "connectionStatus": device.connectionStatus.name
            ]
            if let connectionType = device.connectionType {
                rawDiscoveredDeviceMetadata["connectionType"] = connectionType.name
            }
            defaults.set(rawDiscoveredDeviceMetadata, forKey: key(for: discoveredDevice))
            let _key = key(for: discoveredDevice)
            logger?.debug("set value for key \(_key): \(rawDiscoveredDeviceMetadata)")
        }
        return shouldUpdateDeviceMetadata
    }

    private var isListeningForUpdates: Bool = false
    func listenForUpdates() {
        guard !isListeningForUpdates else { return }
        isListeningForUpdates = true

        scanner.isScanningPublisher.sink { [self] isScanning in
            let newIsScanning = isScanning
            logger?.debug("updating isScanning to \(newIsScanning)")
            defaults.setValue(newIsScanning, forKey: "isScanning")
            reloadTimelines()
        }.store(in: &cancellables)

        BSDeviceManager.availableDevicePublisher.sink { [self] device in
            if devicesCancellables[device.id] == nil {
                devicesCancellables[device.id] = .init()
            }

            device.connectionStatusPublisher.sink { [self] _ in
                guard let discoveredDeviceIndex = scanner.discoveredDevices.firstIndex(where: { $0.device == device }) else {
                    return
                }
                let shouldReload = updateDeviceInformation(for: scanner.discoveredDevices[discoveredDeviceIndex])
                if shouldReload {
                    reloadTimelines()
                }
            }.store(in: &devicesCancellables[device.id]!)
        }.store(in: &cancellables)

        BSDeviceManager.unavailableDevicePublisher.sink { [self] device in
            logger?.debug("removing value for mission \(device.id)")
            devicesCancellables.removeValue(forKey: device.id)
            reloadTimelines()
        }

        scanner.discoveredDevicesPublisher.debounce(for: .seconds(0.5), scheduler: RunLoop.main)
            .sink { [self] discoveredDevices in
                var shouldReloadTimelines = false

                let currentIds = ids
                let newIds = discoveredDevices.compactMap { $0.id }
                logger?.debug("newIds \(newIds, privacy: .public)")
                let idsToRemove = currentIds.filter { !newIds.contains($0) }
                for discoveredDevice in discoveredDevices {
                    shouldReloadTimelines = shouldReloadTimelines || updateDeviceInformation(for: discoveredDevice)
                }

                for item in idsToRemove {
                    defaults.removeObject(forKey: key(id: item))
                    let _key = key(id: item)
                    logger?.debug("removed value for key \(_key)")
                }
                shouldReloadTimelines = shouldReloadTimelines || !idsToRemove.isEmpty

                if currentIds.count != newIds.count || !currentIds.allSatisfy({ newIds.contains($0) }) {
                    shouldReloadTimelines = true
                    defaults.setValue(newIds, forKey: "deviceIds")
                    logger?.debug("updating deviceIds to \(newIds)")
                }

                if shouldReloadTimelines {
                    reloadTimelines()
                }
            }.store(in: &cancellables)
    }

    func reloadTimelines() {
        logger?.debug("(DiscoveredDeviceMetadataManager) reloading timelines")
        // WidgetCenter.shared.reloadTimelines(ofKind: "com.ukaton.demo.device-discovery")
        WidgetCenter.shared.reloadAllTimelines()
    }

    func clear() {
        for id in ids {
            defaults.removeObject(forKey: "device-\(id)")
        }
        defaults.removeObject(forKey: "deviceIds")
        reloadTimelines()
    }
}
