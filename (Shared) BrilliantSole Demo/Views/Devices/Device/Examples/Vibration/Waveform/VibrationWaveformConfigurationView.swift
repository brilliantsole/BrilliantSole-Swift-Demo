//
//  VibrationWaveformConfigurationView.swift
//  BrilliantSoleSwiftDemo
//
//  Created by Zack Qattan on 2/21/25.
//

import BrilliantSole
import SwiftUI

struct VibrationWaveformConfigurationView: View {
    @Binding var configuration: BSVibrationConfiguration

    var body: some View {
        Text("yo")
    }
}

#Preview {
    @Previewable @State var configuration: BSVibrationConfiguration = .init(locations: .all, waveformSegments: .init())

    NavigationStack {
        VibrationWaveformConfigurationView(configuration: $configuration)
    }
    #if os(macOS)
    .frame(maxWidth: 300, maxHeight: 300)
    #endif
}
