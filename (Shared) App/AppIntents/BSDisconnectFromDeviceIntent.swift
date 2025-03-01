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
    static var title = LocalizedStringResource("Disconnect from Device")

    @Parameter(title: "device id")
    var deviceId: String

    init() {}

    init(deviceId: String) {
        self.deviceId = deviceId
    }

    @MainActor
    func perform() async throws -> some IntentResult {
        logger?.debug("disconnecting from device \(deviceId)")
        guard let device = BSDeviceManager.availableDevices.first(where: { $0.id == deviceId }) else {
            logger?.error("no device found with id \(deviceId)")
            return .result()
        }
        device.disconnect()
        return .result()
    }
}
