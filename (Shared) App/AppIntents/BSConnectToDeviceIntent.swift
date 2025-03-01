//
//  BSConnectToDeviceIntent.swift
//  BrilliantSoleSwiftDemo
//
//  Created by Zack Qattan on 2/28/25.
//

import AppIntents
import BrilliantSole
import OSLog

private let logger = getLogger(category: "BSConnectToDeviceIntent", disabled: false)

struct BSConnectToDeviceIntent: AppIntent {
    static var title = LocalizedStringResource("Connect to Device")

    @Parameter(title: "device id")
    var deviceId: String

    @Parameter(title: "connection type")
    var connectionTypeName: String
    var connectionType: BSConnectionType? {
        .init(name: connectionTypeName)
    }

    init() {}

    init(deviceId: String, connectionTypeName: String) {
        self.deviceId = deviceId
        self.connectionTypeName = connectionTypeName
    }

    init(deviceId: String, connectionType: BSConnectionType) {
        self.init(deviceId: deviceId, connectionTypeName: connectionType.name)
    }

    var scanner: BSScanner? { connectionType?.scanner }

    @MainActor
    func perform() async throws -> some IntentResult {
        logger?.debug("connecting to device \(deviceId) via \(connectionType?.name ?? "")")
        guard let connectionType else {
            logger?.error("no connectionType defined")
            return .result()
        }
        guard let scanner else {
            logger?.error("no scanner found")
            return .result()
        }
        guard let discoveredDevice = scanner.discoveredDevicesMap[deviceId] else {
            logger?.error("no discoveredDevice found for deviceId \(deviceId)")
            return .result()
        }
        discoveredDevice.connect()
        return .result()
    }
}
