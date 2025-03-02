//
//  BatteryLevelWidgetConfiguration.swift
//  BrilliantSoleSwiftDemo
//
//  Created by Zack Qattan on 3/1/25.
//

import AppIntents
import BrilliantSole
import SwiftUI
import WidgetKit

extension BatteryLevelWidget {
    func BatteryLevelWidgetConfiguration() -> some WidgetConfiguration {
        StaticConfiguration(kind: "com.brilliantsole.demo.battery-level", provider: BatteryLevelWidgetProvider()) { entry in
            if #available(iOS 17.0, macOS 14.0, watchOS 10.0, *) {
                BatteryLevelWidgetEntryView(entry: entry)
                    .containerBackground(.fill.tertiary, for: .widget)
            } else {
                BatteryLevelWidgetEntryView(entry: entry)
                    .padding()
                    .background()
            }
        }
        .configurationDisplayName("BrilliantSole Battery Level")
        .description("View battery level of your BrilliantSole devices")
        .modify {
            #if WATCHOS
            $0.supportedFamilies([.accessoryCircular, .accessoryRectangular, .accessoryInline, .accessoryCorner])
            #elseif os(iOS)
            $0.supportedFamilies([.accessoryCircular, .accessoryInline, .accessoryRectangular, .systemSmall, .systemMedium, .systemLarge, .systemExtraLarge])
            #elseif os(macOS)
            $0.supportedFamilies([.systemSmall, .systemMedium, .systemLarge, .systemExtraLarge])
            #endif
        }
    }
}
