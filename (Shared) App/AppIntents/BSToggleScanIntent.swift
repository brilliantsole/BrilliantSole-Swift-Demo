//
//  BSToggleScanIntent.swift
//  BrilliantSoleSwiftDemo
//
//  Created by Zack Qattan on 2/28/25.
//

import AppIntents
import BrilliantSole
import OSLog

private let logger = getLogger(category: "BSToggleScanIntent", disabled: false)

struct BSToggleScanIntent: AppIntent {
    #if os(macOS)
    static var openAppWhenRun: Bool = false
    #else
    static var openAppWhenRun: Bool = false
    #endif

    static var title = LocalizedStringResource("Toggle Scan")

    @Parameter(title: "connection type")
    var connectionTypeName: String
    var connectionType: BSConnectionType? {
        .init(name: connectionTypeName)
    }

    init() {}

    init(connectionTypeName: String) {
        self.connectionTypeName = connectionTypeName
    }

    @MainActor
    func perform() async throws -> some IntentResult {
        guard let connectionType else {
            logger?.error("invalid connectionTypeName \(connectionTypeName)")
            return .result()
        }
        logger?.debug("toggling \(connectionType.name) scan")
        connectionType.scanner.toggleScan()
        return .result()
    }
}
