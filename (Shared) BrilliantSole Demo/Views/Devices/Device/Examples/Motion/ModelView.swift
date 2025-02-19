//
//  ModelView.swift
//  BrilliantSoleSwiftDemo
//
//  Created by Zack Qattan on 2/18/25.
//

import BrilliantSole
import Combine
import SceneKit
import Spatial
import SwiftUI

struct ModelView: View {
    let device: BSDevice
    private var recalibrateSubject: PassthroughSubject<Void, Never>? = nil

    // MARK: - SceneKit

    private var scene: SCNScene = .init()
    @State private var model: SCNScene?
    private var lightNode: SCNNode = .init()
    private var cameraNode: SCNNode = .init()

    // MARK: Listeners

    @State var rotation: Rotation3D = .init()
    @State var offsetQuaternion: BSQuaternion = .init(angle: 0, axis: .init(0, 1, 0))
    func updateOffsetQuaternion() {
        let eulerAngles = rotation.eulerAngles(order: .zxy)
        offsetQuaternion = BSQuaternion(angle: -eulerAngles.angles.y, axis: .init(0, 1, 0))
    }

    func onQuaternion(_ quaternion: BSQuaternion) {
        guard let model else { return }
        self.rotation = .init(quaternion)
        model.rootNode.orientation = .init((offsetQuaternion * quaternion).vector)
    }

    func onRotationRate(_ rotationRate: Rotation3D) {
        guard let model else { return }
        var eulerAngles = rotationRate.eulerAngles(order: .xyz)
        eulerAngles.angles *= 2.0
        model.rootNode.eulerAngles = .init(eulerAngles.angles)
    }

    func onLinearAcceleration(_ linearAcceleration: Vector3D) {
        guard let model else { return }
        model.rootNode.simdPosition.interpolate(to: .init(linearAcceleration * 0.05), with: 0.4)
    }

    func onAcceleration(_ acceleration: Vector3D) {
        guard let model else { return }
        model.rootNode.simdPosition.interpolate(to: .init(acceleration * 0.05), with: 0.4)
    }

    // MARK: - Setup

    func setupScene() {
        guard device.isInsole else { return }

        // MARK: - Model

        let modelName = device.deviceType.name
        model = .init(named: "\(modelName).usdz")!
        scene.rootNode.addChildNode(model!.rootNode)
        model!.rootNode.scale = .init(25, 25, 25)

        // MARK: - Lights,

        lightNode.light = .init()
        lightNode.light!.type = .ambient
        scene.rootNode.addChildNode(lightNode)

        // MARK: - Camera...

        cameraNode.camera = SCNCamera()
        cameraNode.position = .init(x: 0, y: 0, z: 15)
        cameraNode.eulerAngles = .init(x: 0, y: 0, z: 0)
        cameraNode.camera?.fieldOfView = 30
            }

    init(device: BSDevice, recalibrateSubject: PassthroughSubject<Void, Never>? = nil) {
        self.device = device
        self.recalibrateSubject = recalibrateSubject
    }

    var body: some View {
        SceneView(scene: scene, pointOfView: cameraNode, options: [.allowsCameraControl])
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .onReceive(device.gameRotationPublisher, perform: { onQuaternion($0.0) })
            .onReceive(device.rotationPublisher, perform: { onQuaternion($0.0) })
            .onReceive(device.orientationPublisher, perform: { onRotationRate($0.0) })
            // .onReceive(device.gyroscopePublisher, perform: { onRotationRate($0.0) })
            .onReceive(device.accelerationPublisher, perform: { onAcceleration($0.0) })
            .onReceive(device.linearAccelerationPublisher, perform: { onLinearAcceleration($0.0) })
            .onAppear {
                if model == nil {
                    setupScene()
                }
            }
            .modify {
                if let recalibrateSubject {
                    $0.onReceive(recalibrateSubject, perform: { _ in
                        updateOffsetQuaternion()
                    })
                }
            }
    }
}

#Preview {
    ModelView(device: .mock)
    #if os(macOS)
        .frame(maxWidth: 360, maxHeight: 500)
    #endif
}
