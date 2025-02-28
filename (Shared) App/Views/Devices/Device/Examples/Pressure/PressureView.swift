//
//  PressureView.swift
//  BrilliantSoleSwiftDemo
//
//  Created by Zack Qattan on 2/21/25.
//

import BrilliantSole
import Combine
import SwiftUI

struct PressureView: View {
    let device: BSDevice
    @State private var pressureData: BSPressureData? = nil

    private let imageNames = (0 ... 7).map { "pressure\($0)" }

    var body: some View {
        ZStack {
            Image(device.deviceType.name)
                .resizable()
            if let pressureData {
                ForEach(Array(imageNames.enumerated()), id: \.element) { index, imageName in
                    Image(imageName)
                        .resizable()
                        .renderingMode(.template)
                        .foregroundColor(.red)
                        .opacity(.init(pressureData.sensors[index].normalizedValue))
                        .scaleEffect(x: device.deviceType == .rightInsole ? 1.0 : -1.0)
                }
            }
        }
        .scaledToFit()
        .onReceive(device.pressureDataPublisher, perform: {
            pressureData = $0.pressure
        })
    }
}

#Preview {
    PressureView(device: .mock)
#if os(macOS)
        .frame(maxWidth: 360, maxHeight: 300)
#endif
}
