//
//  Device.swift
//  BrilliantSoleSwiftDemo
//
//  Created by Zack Qattan on 2/18/25.
//

import BrilliantSole
import Combine
import SwiftUI

struct Device: View {
    let device: BSDevice
    var body: some View {
        List {
            DeviceInformationSection(device: device)
        }.navigationTitle(device.name)
    }
}

#Preview {
    NavigationStack {
        Device(device: .mock)
    }
    .environmentObject(NavigationManager())
    #if os(macOS)
        .frame(maxWidth: 350, minHeight: 300)
    #endif
}
