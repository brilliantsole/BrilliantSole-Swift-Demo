//
//  BalanceExample.swift
//  BrilliantSoleSwiftDemo
//
//  Created by Zack Qattan on 2/27/25.
//

import BrilliantSole
import Combine
import SwiftUI

struct BalanceExample: View {
    let centerOfPressureProvider: BSCenterOfPressureProvider

    var body: some View {
        VStack(spacing: 0) {
            BalanceView(centerOfPressureProvider: centerOfPressureProvider)
            PressureModePicker(sensorConfigurable: centerOfPressureProvider)
        }
        .navigationTitle("Balance")
        .onDisappear {
            centerOfPressureProvider.clearSensorConfiguration()
        }
    }
}

#Preview {
    NavigationStack {
        BalanceExample(centerOfPressureProvider: BSDevicePair.insoles)
    }
    #if os(macOS)
    .frame(maxWidth: 350, minHeight: 300)
    #endif
}
