//
//  BatteryLevelTimelineEntry.swift
//  BrilliantSoleSwiftDemo
//
//  Created by Zack Qattan on 3/1/25.
//

import UkatonMacros
import WidgetKit

struct BatteryLevelTimelineEntry: TimelineEntry {
    let date: Date
    private var ids: [String]?

    private var deviceMetadataManager: DeviceMetadataManager { .shared }

    init(date: Date = .now, ids: [String] = []) {
        self.date = date
        self.ids = ids
    }

    func getMetadata(index: Int) -> DeviceMetadata? {
        if let ids, index < ids.count {
            return getMetadata(id: ids[index])
        }
        else {
            return deviceMetadataManager.getMetadata(index: index)
        }
    }

    func getMetadata(id: String) -> DeviceMetadata? {
        deviceMetadataManager.getMetadata(id: id)
    }
}
