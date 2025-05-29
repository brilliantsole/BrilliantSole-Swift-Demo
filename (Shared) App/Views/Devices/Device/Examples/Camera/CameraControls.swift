//
//  CameraControls.swift
//  BrilliantSoleSwiftDemo
//
//  Created by Zack Qattan on 5/25/25.
//

import BrilliantSole
import Combine
import SwiftUI

struct CameraControls: View {
    let device: BSDevice

    @State private var cameraImageProgress: Float = 0.0
    @State private var cameraStatus: BSCameraStatus = .idle

    @State private var cameraConfiguration: BSCameraConfiguration = .init()

    @State private var tempCameraConfiguration: BSCameraConfiguration = .init()

    @Binding var autoPicture: Bool

    @State private var didWhiteBalanceChangeProgrammatically = false
    @State private var whiteBalance: Color = .white

    private func updateWhiteBalance(isProgrammatic: Bool = true) {
        if let red = cameraConfiguration[.redGain],
           let green = cameraConfiguration[.greenGain],
           let blue = cameraConfiguration[.blueGain]
        {
            let scalar = BSCameraConfigurationType.redGain.range.upperBound
            if isProgrammatic {
                didWhiteBalanceChangeProgrammatically = true
            }
            let newWhiteBalance: Color = .init(red: .init(red) / .init(scalar), green: .init(green) / .init(scalar), blue: .init(blue) / .init(scalar))
            whiteBalance = newWhiteBalance
        }
    }

    init(device: BSDevice, autoPicture: Binding<Bool>) {
        self.device = device
        self._autoPicture = autoPicture
        self._cameraConfiguration = .init(initialValue: device.cameraConfiguration)
        updateWhiteBalance()
    }

    var body: some View {
        VStack {
            HStack(spacing: 0) {
                Button(cameraStatus == .takingPicture ? "\(Int(cameraImageProgress * 100.0))%" : "Take Picture") {
                    device.takePicture()
                }
                .buttonStyle(.borderedProminent)
                .disabled(cameraStatus != .idle)
                .frame(width: 100)

                Button(autoPicture ? "Video" : "Camera") {
                    autoPicture.toggle()
                }
                .buttonStyle(.borderedProminent)
                .frame(width: 70)

                Button(cameraStatus == .focusing ? "Focusing" : "Focus") {
                    device.focusCamera()
                }
                .buttonStyle(.borderedProminent)
                .disabled(cameraStatus != .idle)
                .frame(width: 80)

                Button(cameraStatus == .asleep ? "Wake" : "Sleep") {
                    device.toggleCameraWake()
                }
                .buttonStyle(.borderedProminent)
                .disabled(cameraStatus == .takingPicture || cameraStatus == .focusing)
                .frame(width: 60)
            }

            ForEach(cameraConfiguration.types, id: \.self) { type in
                VStack(alignment: .leading) {
                    let value = tempCameraConfiguration[type] ?? cameraConfiguration[type]!

                    Text("__\(type.name)__: \(value)")
                    Slider(
                        value: Binding<Double>(
                            get: {
                                Double(value)
                            },
                            set: {
                                tempCameraConfiguration[type] = .init($0)
                            }
                        ),
                        in: Double(type.range.lowerBound) ... Double(type.range.upperBound),
                        step: Double(type.step),
                        onEditingChanged: { editing in
                            if !editing, let value = tempCameraConfiguration[type] {
                                device.setCameraConfigurationValue(type, value: value, sendImmediately: false)
                                tempCameraConfiguration[type] = nil
                                device.takePicture()
                            }
                        }
                    )
                    .disabled(cameraStatus != .idle)
                }.padding(.horizontal, 16)
            }
            ColorPicker("__White Balance__", selection: $whiteBalance, supportsOpacity: false)
                .onChange(of: whiteBalance) { _, _ in
                    if didWhiteBalanceChangeProgrammatically {
                        didWhiteBalanceChangeProgrammatically = false
                    }
                    else {
                        #if os(iOS)
                        let color = UIColor(whiteBalance)
                        #elseif os(macOS)
                        let color = NSColor(whiteBalance)
                        #endif

                        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
                        color.getRed(&r, green: &g, blue: &b, alpha: &a)

                        let scalar = CGFloat(BSCameraConfigurationType.redGain.range.upperBound)

                        var cameraConfiguration: BSCameraConfiguration = .init()
                        cameraConfiguration[.redGain] = .init(r * scalar)
                        cameraConfiguration[.greenGain] = .init(g * scalar)
                        cameraConfiguration[.blueGain] = .init(b * scalar)

                        device.setCameraConfiguration(cameraConfiguration)
                    }
                }
        }
        .onReceive(device.cameraStatusPublisher) {
            cameraStatus = $0
        }
        .onReceive(device.cameraImageProgressPublisher) {
            cameraImageProgress = $0
        }
        .onReceive(device.cameraConfigurationPublisher) {
            cameraConfiguration = $0
        }
        .onChange(of: cameraConfiguration) { _, _ in
            updateWhiteBalance()
        }
        .onAppear {
            updateWhiteBalance()
        }
    }
}

#Preview {
    NavigationStack {
        CameraExample(device: .mock)
    }
    #if os(macOS)
    .frame(maxWidth: 300, minHeight: 500)
    #endif
}
