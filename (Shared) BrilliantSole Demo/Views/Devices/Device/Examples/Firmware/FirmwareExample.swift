//
//  FirmwareExample.swift
//  BrilliantSoleSwiftDemo
//
//  Created by Zack Qattan on 2/22/25.
//

import BrilliantSole
import SwiftUI

struct FirmwareExample: View {
    let device: BSDevice

    var body: some View {
        List {
            Text("Hey")
        }
        .navigationTitle("Firmware")
        .onDisappear {
            // FILL - stop uploading firmware
        }
    }
}

#Preview {
    NavigationStack {
        FirmwareExample(device: .mock)
    }
    #if os(macOS)
    .frame(maxWidth: 350, minHeight: 300)
    #endif
}
