//
//  BatteryLevelView.swift
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

@StaticLogger(disabled: false)
struct BatteryLevelView: View {
    init(index: Int) {
        deviceMetadata = DeviceMetadataManager.shared.getMetadata(index: index) ?? .none
        if !deviceMetadata.isConnected, !deviceMetadata.isNone {
            deviceMetadata = .none
        }
        logger?.debug("BatteryLevelView \(index)")
    }

    init(id: String) {
        deviceMetadata = DeviceMetadataManager.shared.getMetadata(id: id) ?? .none
        if !deviceMetadata.isConnected, !deviceMetadata.isNone {
            deviceMetadata = .none
        }
        logger?.debug("BatteryLevelView \(id)")
    }

    init() {
        self.init(index: 0)
    }

    var id: String {
        deviceMetadata.id
    }

    var link: URL {
        .init(string: "brilliantsole-demo://select-device?id=\(id)")!
    }

    var emoji: String {
        switch deviceType {
        case .leftInsole, .rightInsole:
            "👟"
        }
    }

    var deviceMetadata: DeviceMetadata

    var batteryLevel: BSBatteryLevel {
        deviceMetadata.batteryLevel
    }

    var batteryLevelProgress: Double {
        guard !isNone else { return .zero }
        return .init(batteryLevel) / 100
    }

    var batteryLevelView: some View {
        if !isNone {
            Text("\(batteryLevel)%")
        }
        else {
            Text(" ")
        }
    }

    var batteryLevelImageString: String? {
        guard !isNone else { return nil }
        guard !isCharging else { return "battery.100.bolt" }

        return switch batteryLevel {
        case 85 ... 100:
            "battery.100"
        case 65 ... 85:
            "battery.75"
        case 35 ... 65:
            "battery.50"
        case 15 ... 35:
            "battery.25"
        default:
            "battery.0"
        }
    }

    var batteryLevelColor: Color {
        guard !isNone else { return .gray }

        return switch batteryLevel {
        case 60 ... 100:
            .green
        case 10 ... 60:
            .orange
        case 0 ... 10:
            .red
        default:
            .red
        }
    }

    @ViewBuilder
    var batteryLevelImage: some View {
        if let batteryLevelImageString {
            Image(systemName: batteryLevelImageString)
                .foregroundColor(batteryLevelColor)
        }
    }

    var isCharging: Bool {
        deviceMetadata.isCharging
    }

    var deviceType: BSDeviceType {
        deviceMetadata.deviceType
    }

    var isNone: Bool {
        deviceMetadata.isNone
    }

    var name: String {
        deviceMetadata.name
    }

    @Environment(\.widgetFamily) var family

    var imageName: String? {
        guard !isNone else { return nil }

        return switch deviceType {
        case .leftInsole, .rightInsole:
            "shoe.fill"
        }
    }

    private var imageScale: Image.Scale {
        switch family {
        case .accessoryCircular:
            .large

        case .accessoryCorner:
            .small

        case .accessoryRectangular:
            .small

        case .systemSmall:
            #if os(iOS)
                .medium
            #else
                .large
            #endif

        case .systemMedium, .systemLarge, .systemExtraLarge:
            .large

        default:
            .medium
        }
    }

    @ViewBuilder
    private var image: some View {
        if let imageName {
            Image(systemName: imageName)
                .imageScale(imageScale)
                .modify {
                    if deviceType == .leftInsole {
                        $0.scaleEffect(x: -1)
                    }
                }
        }
    }

    var body: some View {
        if isNone {
            _body
        }
        else {
            Link(destination: link) {
                _body
            }
        }
    }

    var circleBody: some View {
        ZStack {
            let yOffset: CGFloat = switch family {
            case .systemMedium:
                0
            default:
                -6
            }

            image
            ProgressView(value: .init(batteryLevelProgress))
                .progressViewStyle(.circular)
                .tint(batteryLevelColor)
                .modify {
                    if isCharging {
                        $0.overlay(
                            VStack {
                                let radius: CGFloat = switch family {
                                case .systemMedium:
                                    7
                                default:
                                    7
                                }
                                let maskYOffset: CGFloat = switch family {
                                case .systemMedium:
                                    2
                                default:
                                    9
                                }
                                Circle()
                                    .frame(width: radius*2, height: radius*2)
                                    .blendMode(.destinationOut)
                                    .offset(y: yOffset - radius + maskYOffset)
                                Spacer()
                            }
                        )
                        .compositingGroup()
                    }
                }

            if isCharging {
                VStack {
                    Image(systemName: "bolt.fill")
                        .imageScale(.small)
                        .offset(y: yOffset)
                    Spacer()
                }
            }
        }
        .frame(maxHeight: 80)
        .modify {
            #if os(watchOS)
                $0.widgetLabel {
                    Text("\(name)")
                }
            #endif
        }
    }

    @ViewBuilder
    var _body: some View {
        switch family {
        case .accessoryInline:
            if !isNone {
                HStack {
                    image
                    if isCharging {
                        Image(systemName: "bolt.fill")
                    }
                    Text("\(name) \(batteryLevel)%")
                }
            }
        case .accessoryCorner:
            HStack {
                if !isNone {
                    Text("\(emoji) \(batteryLevel)%")
                        .tint(batteryLevelColor)
                        .minimumScaleFactor(0.5)
                }
            }
            .modify {
                #if os(watchOS)
                    $0.widgetCurvesContent()
                        .widgetLabel {
                            ProgressView(value: .init(batteryLevelProgress))
                                .tint(batteryLevelColor)
                        }
                #endif
            }
        case .accessoryRectangular:
            if BatteryLevelWidgetEntryView.onlyShowSingleViewForAccessoryRectangular {
                VStack {
                    HStack {
                        image
                        if isCharging {
                            Image(systemName: "bolt.fill")
                        }
                        batteryLevelView
                            .fontWeight(.semibold)
                        Spacer()
                    }
                    HStack {
                        if !isNone {
                            Text("\(name)")
                        }
                        else {
                            Text("no device connected")
                        }
                        Spacer()
                    }
                    ProgressView(value: .init(batteryLevelProgress))
                        .tint(batteryLevelColor)
                        .modify {
                            #if os(iOS)
                                $0.scaleEffect(x: 1, y: 2, anchor: .center)
                                    .offset(y: -2)
                            #else
                            #endif
                        }
                    Spacer()
                }
            }
            else {
                VStack {
                    circleBody
                    batteryLevelView
                }
            }
        case .systemSmall, .accessoryCircular:
            circleBody
        case .systemMedium:
            VStack(spacing: 8) {
                circleBody
                batteryLevelView
                    .font(.title2)
            }
        case .systemLarge, .systemExtraLarge:
            HStack {
                image
                Text("\(name)")
                Spacer()
                batteryLevelView
                batteryLevelImage
            }
            .font(.subheadline)
        default:
            Text("uncaught family \(family.debugDescription)")
        }
    }
}
