//
//  ScannerWidgetConfiguration.swift
//  BrilliantSoleSwiftDemo
//
//  Created by Zack Qattan on 2/28/25.
//

import AppIntents
import SwiftUI
import WidgetKit

extension ScannerWidget {
    func ScannerWidgetConfiguration() -> some WidgetConfiguration {
        StaticConfiguration(kind: "com.brilliantsole.widget.scanner", provider: ScannerWidgetProvider()) { entry in
            if #available(iOS 17.0, macOS 14.0, *) {
                ScannerWidgetEntryView(entry: entry)
                    .containerBackground(.fill.tertiary, for: .widget)
            } else {
                ScannerWidgetEntryView(entry: entry)
                    .padding()
                    .background()
            }
        }
        .configurationDisplayName("BrilliantSole Scanner")
        .description("Scan for BrilliantSole Devices")
        .modify {
            $0.supportedFamilies([.systemLarge])
        }
    }
}
