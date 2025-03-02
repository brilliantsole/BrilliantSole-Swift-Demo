//
//  BSDisconnectFromDeviceIntent.swift
//  BrilliantSoleSwiftDemo
//
//  Created by Zack Qattan on 2/28/25.
//

import AppIntents
import BrilliantSole
import OSLog

private let logger = getLogger(category: "BSDisconnectFromDeviceIntent", disabled: false)

struct BSDisconnectFromDeviceIntent: AppIntent {
    #if os(macOS)
    static var openAppWhenRun: Bool = true
    #endif

    static var title = LocalizedStringResource("Disconnect from Device")

    @Parameter(title: "connection id")
    var connectionId: String

    init() {}

    init(connectionId: String) {
        self.connectionId = connectionId
    }

    @MainActor
    func perform() async throws -> some IntentResult {
        logger?.debug("disconnecting from device \(connectionId)")
        guard let device = BSDeviceManager.availableDevices.first(where: { $0.connectionId == connectionId }) else {
            logger?.error("no device found with id \(connectionId)")
            return .result()
        }
        device.disconnect()
        return .result()
    }
}
