//
//  DeviceDiscovery.swift
//  BrilliantSoleSwiftDemo
//
//  Created by Zack Qattan on 2/10/25.
//

import SwiftUI

struct DeviceDiscovery: View {
    var body: some View {
        Text("Device Discovery")
    }
}

#Preview {
    DeviceDiscovery()
    #if os(macOS)
        .frame(maxWidth: 350, minHeight: 300)
    #endif
}
