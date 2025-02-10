//
//  ContentView.swift
//  BrilliantSoleSwiftDemo
//
//  Created by Zack Qattan on 1/15/25.
//

import BrilliantSole
import OSLog
import SwiftUI
import UkatonMacros

@StaticLogger
struct ContentView: View {
    @EnumName
    enum TabEnum: Identifiable {
        var id: String { name }

        case deviceDiscovery
        case devicePair

        var requiresDevicePair: Bool {
            switch self {
            case .devicePair:
                true
            default:
                false
            }
        }
    }

    private let devicePair: BSDevicePair = .shared
    var devicePairImageString: String {
        if devicePair.isFullyConnected {
            return "shoe.2.fill"
        }
        else if devicePair.isHalfConnected {
            return "shoe.fill"
        }
        else {
            return "circle.dashed"
        }
    }

    @State private var selectedTab: TabEnum = .deviceDiscovery

    var body: some View {
        TabView(selection: $selectedTab) {
            DeviceDiscovery()
                .modify {
                    if !isWatch {
                        $0.tabItem {
                            Label("Device Discovery", systemImage: "magnifyingglass")
                        }
                    }
                }
                .tag(TabEnum.deviceDiscovery)

            DevicePair()
                .modify {
                    if !isWatch {
                        $0.tabItem {
                            Label("Device Pair", systemImage: devicePairImageString)
                        }
                    }
                }
                .tag(TabEnum.devicePair)
        }
    }
}

#Preview {
    ContentView()
    #if os(macOS)
        .frame(maxWidth: 410, minHeight: 300)
    #endif
}
