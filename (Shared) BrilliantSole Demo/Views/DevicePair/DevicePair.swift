//
//  DevicePair.swift
//  BrilliantSoleSwiftDemo
//
//  Created by Zack Qattan on 2/10/25.
//

import SwiftUI

struct DevicePair: View {
    var body: some View {
        Text("Device Pair")
    }
}

#Preview {
    DevicePair()
#if os(macOS)
        .frame(maxWidth: 350, maxHeight: 300)
#endif
}
