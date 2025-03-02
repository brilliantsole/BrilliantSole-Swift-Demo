//
//  WidgetBundle.swift
//  Widget
//
//  Created by Zack Qattan on 2/28/25.
//

import SwiftUI
import WidgetKit

@main
struct BSWidgetBundle: WidgetBundle {
    var body: some Widget {
        BatteryLevelWidget()
        #if !os(watchOS)
        ScannerWidget()
        #endif
    }
}
