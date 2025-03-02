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

@StaticLogger(disabled: false)
@Singleton()
class DiscoveredDeviceMetadataManager {
    private let defaults: UserDefaults? = getUserDefaults("discovered-devices")

    var scanner: BSScanner {
        BSConnectionType.ble.scanner
    }

    var ids: [String] {
        defaults?.object(forKey: "deviceIds") as? [String] ?? []
    }

    var isScanning: Bool {
        defaults?.object(forKey: "isScanning") as? Bool ?? false
    }

    func getMetadata(id: String) -> DiscoveredDeviceMetadata? {
        guard let value = defaults?.object(forKey: "device-\(id)") as? RawDiscoveredDeviceMetadata,
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

    func getMetadata(index: Int) -> DiscoveredDeviceMetadata? {
        guard index < ids.count else { return nil }
        return getMetadata(id: ids[index])
    }

    private func key(for discoveredDevice: BSDiscoveredDevice) -> String {
        key(id: discoveredDevice.id)
    }

    private func key(id: String) -> String {
        "device-\(id)"
    }

    private var cancellables: Set<AnyCancellable> = .init()
    private var discoveredDevicesCancellables: [String: Set<AnyCancellable>] = .init()
    private func updateDiscoveredDeviceMetadata(for discoveredDevice: BSDiscoveredDevice) -> Bool {
        var shouldUpdateDiscoveredDeviceMetadata = false
        if let discoveredDeviceMetadata = getMetadata(id: discoveredDevice.id) {
            if discoveredDevice.name != discoveredDeviceMetadata.name ||
                discoveredDevice.deviceType != discoveredDeviceMetadata.deviceType ||
                discoveredDevice.isConnected != discoveredDeviceMetadata.isConnected ||
                discoveredDevice.connectionStatus != discoveredDeviceMetadata.connectionStatus ||
                discoveredDevice.connectionType != discoveredDeviceMetadata.connectionType
            {
                shouldUpdateDiscoveredDeviceMetadata = true
            }
        }
        else {
            shouldUpdateDiscoveredDeviceMetadata = true
        }

        if shouldUpdateDiscoveredDeviceMetadata {
            var rawDiscoveredDeviceMetadata: RawDiscoveredDeviceMetadata = [
                "name": discoveredDevice.name,
                "deviceType": discoveredDevice.deviceType.name,
                "connectionStatus": discoveredDevice.connectionStatus.name
            ]
            if let connectionType = discoveredDevice.connectionType {
                rawDiscoveredDeviceMetadata["connectionType"] = connectionType.name
            }
            defaults?.set(rawDiscoveredDeviceMetadata, forKey: key(for: discoveredDevice))
            let _key = key(for: discoveredDevice)
            logger?.debug("set value for key \(_key, privacy: .public): \(rawDiscoveredDeviceMetadata, privacy: .public)")
        }
        return shouldUpdateDiscoveredDeviceMetadata
    }

    private var isListeningForUpdates: Bool = false
    func listenForUpdates() {
        guard !isListeningForUpdates else { return }
        isListeningForUpdates = true

        cancellables.removeAll()

        logger?.debug("listening for DiscoveredDeviceMetadata updates")

        scanner.isScanningPublisher.sink { [self] isScanning in
            let newIsScanning = isScanning
            logger?.debug("updating isScanning to \(newIsScanning)")
            defaults?.setValue(newIsScanning, forKey: "isScanning")
            reloadTimelines()
        }.store(in: &cancellables)

        scanner.discoveredDevicePublisher.sink { [self] discoveredDevice in
            if discoveredDevicesCancellables[discoveredDevice.id] == nil {
                discoveredDevicesCancellables[discoveredDevice.id] = .init()
            }
            discoveredDevice.connectionStatusPublisher.sink { [self] _ in
                Task {
                    logger?.debug("updating connectionStatus for \(discoveredDevice.name, privacy: .public)")
                    let shouldReload = updateDiscoveredDeviceMetadata(for: discoveredDevice)
                    if shouldReload {
                        reloadTimelines()
                    }
                }
            }.store(in: &discoveredDevicesCancellables[discoveredDevice.id]!)
        }.store(in: &cancellables)

        scanner.expiredDiscoveredDevicePublisher.sink { [self] expiredDiscoveredDevice in
            logger?.debug("removing discoveredDevicesCancellables for \(expiredDiscoveredDevice.name, privacy: .public)")
            discoveredDevicesCancellables.removeValue(forKey: expiredDiscoveredDevice.id)
        }.store(in: &cancellables)

        scanner.discoveredDevicesPublisher.debounce(for: .seconds(0.5), scheduler: RunLoop.main)
            .sink { [self] discoveredDevices in
                var shouldReloadTimelines = false

                let oldIds = ids
                let currentIds = discoveredDevices.compactMap { $0.id }
                logger?.debug("currentIds \(currentIds, privacy: .public)")
                let idsToRemove = oldIds.filter { !currentIds.contains($0) }
                for discoveredDevice in discoveredDevices {
                    let shouldUpdateDiscoveredDeviceMetadata = updateDiscoveredDeviceMetadata(for: discoveredDevice)
                    shouldReloadTimelines = shouldReloadTimelines || shouldUpdateDiscoveredDeviceMetadata
                }

                for item in idsToRemove {
                    defaults?.removeObject(forKey: key(id: item))
                    discoveredDevicesCancellables.removeValue(forKey: item)
                    let _key = key(id: item)
                    logger?.debug("removed value for key \(_key)")
                }
                shouldReloadTimelines = shouldReloadTimelines || !idsToRemove.isEmpty

                if oldIds.count != currentIds.count || !oldIds.allSatisfy({ currentIds.contains($0) }) {
                    shouldReloadTimelines = true
                    defaults?.setValue(currentIds, forKey: "deviceIds")
                    logger?.debug("updating deviceIds to \(currentIds)")
                }

                if shouldReloadTimelines {
                    reloadTimelines()
                }
            }.store(in: &cancellables)
    }

    func reloadTimelines() {
        logger?.debug("reloading timelines")
        // WidgetCenter.shared.reloadTimelines(ofKind: "com.brilliantsole.widget.scanner")
        WidgetCenter.shared.reloadAllTimelines()
    }

    func clear() {
        logger?.log("clear")
        for id in ids {
            logger?.log("removing object for key \("device-\(id)")")
            defaults?.removeObject(forKey: "device-\(id)")
        }
        logger?.log("removing object for key \"deviceIds\"")
        defaults?.removeObject(forKey: "deviceIds")
        reloadTimelines()
    }
}
