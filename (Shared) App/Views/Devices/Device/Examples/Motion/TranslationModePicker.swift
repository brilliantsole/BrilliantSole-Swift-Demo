//
//  TranslationModePicker.swift
//  BrilliantSoleSwiftDemo
//
//  Created by Zack Qattan on 2/18/25.
//

import BrilliantSole
import SwiftUI
import UkatonMacros

struct TranslationModePicker: View {
    let sensorConfigurable: BSSensorConfigurable

    @EnumName
    enum TranslationMode: CaseIterable, Identifiable, Hashable {
        var id: String { name }

        case noTranslation
        case linearAcceleration
        case acceleration

        var sensorType: BSSensorType? {
            return switch self {
            case .noTranslation:
                nil
            case .acceleration:
                .acceleration
            case .linearAcceleration:
                .linearAcceleration
            }
        }

        var showSensorType: Bool {
            true
        }
    }

    @State private var translationMode: TranslationMode = .noTranslation

    var body: some View {
        HStack {
            Picker(selection: $translationMode, label: EmptyView()) {
                ForEach(TranslationMode.allCases) { translationMode in
                    if translationMode.showSensorType {
                        Text(translationMode.name)
                            .tag(translationMode)
                    }
                }
            }
            #if os(tvOS)
            .pickerStyle(.menu)
            #else
            .pickerStyle(.segmented)
            #endif
            .onChange(of: translationMode) { _, newTranslationMode in
                var sensorConfiguration: BSSensorConfiguration = .init()
                for translationMode in TranslationMode.allCases {
                    guard let sensorType = translationMode.sensorType else { continue }

                    sensorConfiguration[sensorType] = ._0ms
                }
                if let sensorType = newTranslationMode.sensorType {
                    sensorConfiguration[sensorType] = ._20ms
                }
                self.translationMode = newTranslationMode
                sensorConfigurable.setSensorConfiguration(sensorConfiguration)
            }
        }
    }
}

#Preview {
    TranslationModePicker(sensorConfigurable: BSDevice.mock)
    #if os(macOS)
        .frame(maxWidth: 300)
    #endif
}
