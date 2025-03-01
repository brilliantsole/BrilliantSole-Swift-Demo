//
//  ScannerWidget.swift
//  BrilliantSoleSwiftDemo
//
//  Created by Zack Qattan on 2/28/25.
//

import SwiftUI
import WidgetKit

struct ScannerWidget: Widget {
    var body: some WidgetConfiguration {
        ScannerWidgetConfiguration()
    }
}

#if os(iOS) || os(macOS)
#Preview("systemLarge", as: .systemLarge) {
    ScannerWidget()
} timeline: {
    ScannerTimelineEntry(date: .now)
}
#endif
