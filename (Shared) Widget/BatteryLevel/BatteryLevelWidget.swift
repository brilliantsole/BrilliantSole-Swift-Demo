//
//  BatteryLevelWidget.swift
//  BrilliantSoleSwiftDemo
//
//  Created by Zack Qattan on 2/28/25.
//

import AppIntents
import BrilliantSole
import OSLog
import SwiftUI
import UkatonMacros
import WidgetKit

@StaticLogger
struct BatteryLevelWidget: Widget {
    var body: some WidgetConfiguration {
        BatteryLevelWidgetConfiguration()
    }
}

#if os(iOS)
#Preview("accessoryCircular", as: .accessoryCircular) {
    BatteryLevelWidget()
} timeline: {
    BatteryLevelTimelineEntry(date: .now)
}

#Preview("accessoryInline", as: .accessoryInline) {
    BatteryLevelWidget()
} timeline: {
    BatteryLevelTimelineEntry(date: .now)
}

#Preview("accessoryRectangular", as: .accessoryRectangular) {
    BatteryLevelWidget()
} timeline: {
    BatteryLevelTimelineEntry(date: .now)
}
#endif

#if os(iOS) || os(macOS)
#Preview("systemSmall", as: .systemSmall) {
    BatteryLevelWidget()
} timeline: {
    BatteryLevelTimelineEntry(date: .now)
}

#Preview("systemMedium", as: .systemMedium) {
    BatteryLevelWidget()
} timeline: {
    BatteryLevelTimelineEntry(date: .now)
}

#Preview("systemLarge", as: .systemLarge) {
    BatteryLevelWidget()
} timeline: {
    BatteryLevelTimelineEntry(date: .now)
}

#Preview("systemExtraLarge", as: .systemExtraLarge) {
    BatteryLevelWidget()
} timeline: {
    BatteryLevelTimelineEntry(date: .now)
}
#endif
