//
//  ScannerTimelineEntry.swift
//  BrilliantSoleSwiftDemo
//
//  Created by Zack Qattan on 2/28/25.
//

import WidgetKit

struct ScannerTimelineEntry: TimelineEntry {
    let date: Date
    private var deviceIds: [String]?

    private var deviceMetadataManager: DeviceMetadataManager { .shared }

    init(date: Date = .now, deviceIds: [String] = []) {
        self.date = date
        self.deviceIds = deviceIds
    }

    func getInformation(index: Int) -> DeviceMetadata? {
        if let deviceIds, index < deviceIds.count {
            return getMetadata(id: deviceIds[index])
        }
        else {
            return deviceMetadataManager.getMetadata(index: index)
        }
    }

    func getMetadata(id: String) -> DeviceMetadata? {
        deviceMetadataManager.getMetadata(id: id)
    }
}
