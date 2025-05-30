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

        let slerpedQuaternion = simd_slerp(rotation.quaternion, quaternion, 0.2)

        rotation = .init(slerpedQuaternion)

        model.rootNode.orientation = .init((offsetQuaternion * slerpedQuaternion).vector)
    }

    func onRotation(_ rotation: Rotation3D) {
        onQuaternion(rotation.quaternion)
    }

    func onGyroscope(_ gyroscope: Vector3D) {
        guard let model else { return }
        let pitch: Angle2D = .init(degrees: gyroscope.x)
        let yaw: Angle2D = .init(degrees: gyroscope.y)
        let roll: Angle2D = .init(degrees: gyroscope.z)
        var eulerAngles: EulerAngles = .init(x: pitch, y: yaw, z: roll, order: .xyz)
        eulerAngles.angles *= 0.5
        model.rootNode.eulerAngles = .init(eulerAngles.angles)
    }

    func onVector(_ vector: Vector3D) {
        guard let model else { return }
        let _vector = model.rootNode.simdOrientation.act(.init(vector))
        model.rootNode.simdPosition.interpolate(to: _vector * 3, with: 0.3)
    }

    func onLinearAcceleration(_ linearAcceleration: Vector3D) {
        onVector(linearAcceleration)
    }

    func onAcceleration(_ acceleration: Vector3D) {
        onVector(acceleration)
    }

    // MARK: - Setup

    func setupScene() {
        guard model == nil else {
            print("already loaded model")
            return
        }

        #if os(watchOS) || os(iOS)
            scene.background.contents = UIColor.white
        #endif

        // MARK: - Model

        let deviceType = device.deviceType
        // let deviceType: BSDeviceType = .glasses
        let modelName = switch deviceType {
        case .leftInsole, .rightInsole:
            "right insole"
        case .leftGlove, .rightGlove:
            "right glove"
        case .glasses:
            "glasses"
        case .generic:
            "generic"
        }
        model = .init(named: "\(modelName).usdz")!
        guard let model else {
            print("failed to load model")
            return
        }

        scene.rootNode.addChildNode(model.rootNode)
        switch deviceType {
        case .leftInsole, .rightInsole:
            model.rootNode.scale = .init(25 * (deviceType.side == .right ? 1 : -1), 25, 25)
        case .rightGlove, .leftGlove:
            model.rootNode.scale = .init(1.5 * (deviceType.side == .right ? 1 : -1), 1.5, 1.5)
        case .glasses:
            model.rootNode.scale = .init(25, 25, 25)
        // model.rootNode.position = .init(0, 0.5, 0)
        case .generic:
            model.rootNode.scale = .init(0.06, 0.06, 0.06)
            model.rootNode.position = .init(0, -1, 0)
        }
        // model.rootNode.eulerAngles.x = .pi / 2

        // MARK: - Lights,

        lightNode.light = .init()
        lightNode.light!.type = .ambient
        scene.rootNode.addChildNode(lightNode)

        // MARK: - Camera...

        cameraNode.camera = SCNCamera()

        if isTv {
            cameraNode.position = .init(x: 0, y: 15, z: 0)
            cameraNode.eulerAngles = .init(x: -.pi / 2, y: 0, z: 0)
        }
        else {
            cameraNode.position = .init(x: 0, y: 0, z: 15)
            cameraNode.eulerAngles = .init(x: 0, y: 0, z: 0)
        }
        cameraNode.camera?.fieldOfView = 30
    }

    init(device: BSDevice, recalibrateSubject: PassthroughSubject<Void, Never>? = nil) {
        self.device = device
        self.recalibrateSubject = recalibrateSubject
    }

    var body: some View {
        SceneView(scene: scene, pointOfView: cameraNode, options: [.allowsCameraControl])
            .clipShape(RoundedRectangle(cornerRadius: 16))
        #if os(watchOS) || os(iOS)
            .background(Color.white)
        #endif
            .onReceive(device.gameRotationPublisher, perform: { onQuaternion($0.quaternion) })
            .onReceive(device.rotationPublisher, perform: { onQuaternion($0.quaternion) })
            .onReceive(device.orientationPublisher, perform: { onRotation($0.rotation) })
            .onReceive(device.gyroscopePublisher, perform: { onGyroscope($0.vector) })
            .onReceive(device.accelerationPublisher, perform: { onAcceleration($0.vector) })
            .onReceive(device.linearAccelerationPublisher, perform: { onLinearAcceleration($0.vector) })
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
