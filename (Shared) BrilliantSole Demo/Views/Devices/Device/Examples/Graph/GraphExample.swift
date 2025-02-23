//
//  GraphExample.swift
//  BrilliantSoleSwiftDemo
//
//  Created by Zack Qattan on 2/22/25.
//

import BrilliantSole
import SwiftUI

struct GraphExample: View {
    let device: BSDevice

    var body: some View {
        VStack {
            Text("Graph")
        }
        .navigationTitle("Graph")
        .onDisappear {
            device.clearSensorConfiguration()
        }
    }
}

#Preview {
    NavigationStack {
        GraphExample(device: .mock)
    }
    #if os(macOS)
    .frame(maxWidth: 350, minHeight: 300)
    #endif
}
