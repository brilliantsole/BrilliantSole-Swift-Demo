//
//  BatteryLevelWidgetEntryView.swift
//  BrilliantSoleSwiftDemo
//
//  Created by Zack Qattan on 3/1/25.
//

import AppIntents
import BrilliantSole
import SwiftUI
import WidgetKit

struct BatteryLevelWidgetEntryView: View {
    var entry: BatteryLevelWidgetProvider.Entry

    @Environment(\.widgetFamily) var family

    var spacing: CGFloat = 12

    var accessoryCircularBody: some View {
        BatteryLevelView()
    }

    var accessoryInlineBody: some View {
        BatteryLevelView()
    }

    public static var onlyShowSingleViewForAccessoryRectangular: Bool = is_iOS
    @ViewBuilder
    var accessoryRectangularBody: some View {
        if Self.onlyShowSingleViewForAccessoryRectangular {
            BatteryLevelView()
        }
        else {
            HStack(spacing: 8) {
                BatteryLevelView(index: 0)
                BatteryLevelView(index: 1)
                BatteryLevelView(index: 2)
            }
        }
    }

    var accessoryCornerBody: some View {
        BatteryLevelView()
    }

    var systemSmallBody: some View {
        VStack(spacing: spacing) {
            HStack(spacing: spacing) {
                BatteryLevelView(index: 0)
                BatteryLevelView(index: 1)
            }
            HStack(spacing: spacing) {
                BatteryLevelView(index: 2)
                BatteryLevelView(index: 3)
            }
        }
    }

    var systemMediumBody: some View {
        HStack(spacing: spacing) {
            ForEach(0 ..< 4) {
                BatteryLevelView(index: $0)
            }
        }
    }

    var systemLargeBody: some View {
        VStack(spacing: spacing + 4) {
            ForEach(0 ..< 6) {
                BatteryLevelView(index: $0)
                Divider()
            }
        }
    }

    var systemExtraLargeBody: some View {
        VStack(spacing: spacing + 4) {
            ForEach(0 ..< 6) {
                BatteryLevelView(index: $0)
                Divider()
            }
        }
    }

    var uncaughtBody: some View {
        Text("uncaught widget family")
            .unredacted()
    }

    #if WATCHOS
        var body: some View {
            switch family {
            case .accessoryCircular:
                accessoryCircularBody
            case .accessoryInline:
                accessoryCircularBody
            case .accessoryRectangular:
                accessoryRectangularBody
            case .accessoryCorner:
                accessoryCornerBody
            default:
                uncaughtBody
            }
        }

    #elseif os(iOS)
        var body: some View {
            switch family {
            case .accessoryCircular:
                accessoryCircularBody
            case .accessoryInline:
                accessoryInlineBody
            case .accessoryRectangular:
                accessoryRectangularBody
            case .systemSmall:
                systemSmallBody
            case .systemMedium:
                systemMediumBody
            case .systemLarge:
                systemLargeBody
            default:
                uncaughtBody
            }
        }

    #elseif os(macOS)
        var body: some View {
            switch family {
            case .systemSmall:
                systemSmallBody
            case .systemMedium:
                systemMediumBody
            case .systemLarge:
                systemLargeBody
            case .systemExtraLarge:
                systemExtraLargeBody
            default:
                uncaughtBody
            }
        }
    #endif
}
