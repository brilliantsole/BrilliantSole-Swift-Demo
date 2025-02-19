//
//  MotionExample.swift
//  BrilliantSoleSwiftDemo
//
//  Created by Zack Qattan on 2/18/25.
//

import BrilliantSole
import Combine
import SwiftUI

struct MotionExample: View {
    let device: BSDevice

    var body: some View {
        VStack {
            Text("hey")
        }
        .navigationTitle("Motion")
    }
}

#Preview {
    MotionExample(device: .mock)
    #if os(macOS)
        .frame(maxWidth: 350, minHeight: 300)
    #endif
}
