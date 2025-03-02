//
//  BatteryLevelWidgetProvider.swift
//  BrilliantSoleSwiftDemo
//
//  Created by Zack Qattan on 3/1/25.
//

import AppIntents
import BrilliantSole
import OSLog
import SwiftUI
import UkatonMacros
import WidgetKit

@StaticLogger
struct BatteryLevelWidgetProvider: TimelineProvider {
    typealias Entry = BatteryLevelTimelineEntry

    var deviceMetadataManager: DeviceMetadataManager { .shared }

    func getSnapshot(in context: Context, completion: @escaping (Entry) -> ()) {
        let entry = Entry()
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        let entry = Entry()
        let entries = [entry]
        let timeline = Timeline(entries: entries, policy: .never)
        completion(timeline)
    }

    func placeholder(in context: Context) -> Entry {
        logger?.debug("requesting placeholder for \(context.family.debugDescription, privacy: .public)")
        return .init(date: .now)
    }
}
