//
//  BSConnectToDeviceIntent.swift
//  BrilliantSoleSwiftDemo
//
//  Created by Zack Qattan on 2/28/25.
//

import AppIntents
import BrilliantSole
import OSLog

private let logger = getLogger(category: "BSConnectToDeviceIntent", disabled: true)

struct BSConnectToDeviceIntent: AppIntent {
    static var openAppWhenRun: Bool = true

    static var title = LocalizedStringResource("Connect to Device")

    @Parameter(title: "connection id")
    var connectionId: String

    @Parameter(title: "connection type")
    var connectionTypeName: String
    var connectionType: BSConnectionType? {
        .init(name: connectionTypeName)
    }

    init() {}

    init(connectionId: String, connectionTypeName: String) {
        self.connectionId = connectionId
        self.connectionTypeName = connectionTypeName
    }

    init(connectionId: String, connectionType: BSConnectionType) {
        self.init(connectionId: connectionId, connectionTypeName: connectionType.name)
    }

    var scanner: BSScanner? { connectionType?.scanner }

    @MainActor
    func perform() async throws -> some IntentResult {
        logger?.debug("connecting to device \(connectionId) via \(connectionType?.name ?? "")")
        guard let scanner else {
            logger?.error("no scanner found")
            return .result()
        }
        guard let discoveredDevice = scanner.discoveredDevicesMap[connectionId] else {
            logger?.error("no discoveredDevice found for connectionId \(connectionId)")
            return .result()
        }
        discoveredDevice.connect()
        return .result()
    }
}
