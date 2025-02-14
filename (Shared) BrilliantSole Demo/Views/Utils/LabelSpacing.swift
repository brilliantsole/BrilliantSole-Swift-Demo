//
//  LabelSpacing.swift
//  BrilliantSoleSwiftDemo
//
//  Created by Zack Qattan on 2/14/25.
//

import SwiftUI

struct LabelSpacing: LabelStyle {
    var spacing: Double = 0.0

    func makeBody(configuration: Configuration) -> some View {
        HStack(spacing: spacing) {
            configuration.icon
            configuration.title
        }
    }
}

#Preview {
    Label("hey", systemImage: "wifi")
        .labelStyle(LabelSpacing(spacing: 4))
}
