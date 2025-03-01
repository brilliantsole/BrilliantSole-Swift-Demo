//
//  StringUtils.swift
//  BrilliantSoleSwiftDemo
//
//  Created by Zack Qattan on 2/27/25.
//

import BrilliantSole
import Foundation

public extension BSTimestamp {
    var timestampString: String {
        let totalSeconds = self / 1000
        let minutes = (totalSeconds / 60) % 60
        let seconds = totalSeconds % 60
        let milliseconds = self % 1000

        return String(format: "%02d:%02d:%03d", minutes, seconds, milliseconds)
    }
}

public extension BSCenterOfPressure {
    var centerOfPressureString: String {
        .init(format: "x: %5.3f, y: %5.3f", x, y)
    }

    var array: [Double] {
        [x, y]
    }
}

private let vector3DNumberFormatter: NumberFormatter = {
    let nf = NumberFormatter()
    nf.numberStyle = .decimal
    nf.minimumIntegerDigits = 2
    nf.minimumFractionDigits = 3
    nf.maximumFractionDigits = 3
    nf.positivePrefix = " "
    nf.paddingCharacter = "0"
    nf.paddingPosition = .afterSuffix
    return nf
}()

public extension BSVector3D {
    fileprivate var nf: NumberFormatter { vector3DNumberFormatter }
    var strings: [String] {
        [
            "x:\(nf.string(for: x)!)",
            "y:\(nf.string(for: y)!)",
            "z:\(nf.string(for: z)!)",
        ]
    }

    var string: String {
        strings.joined(separator: isWatch ? "\n" : ", ")
    }

    var array: [Double] {
        [x, y, z]
    }
}

private let rotation3DNumberFormatter: NumberFormatter = {
    let nf = NumberFormatter()
    nf.numberStyle = .decimal
    nf.minimumIntegerDigits = 1
    nf.minimumFractionDigits = 4
    nf.maximumFractionDigits = 4
    nf.positivePrefix = " "
    nf.paddingCharacter = "0"
    nf.paddingPosition = .afterSuffix
    return nf
}()

public extension BSRotation3D {
    fileprivate var nf: NumberFormatter { rotation3DNumberFormatter }
    var strings: [String] {
        let angles = eulerAngles(order: .zxy).angles
        return [
            "p:\(nf.string(for: angles.x)!)",
            "y:\(nf.string(for: angles.y)!)",
            "r:\(nf.string(for: angles.z)!)",
        ]
    }

    var string: String {
        strings.joined(separator: isWatch ? "\n" : ", ")
    }

    var array: [Double] {
        let angles = eulerAngles(order: .zxy).angles
        return [angles.x, angles.y, angles.z]
    }
}

private let quaternionNumberFormatter: NumberFormatter = {
    let nf = NumberFormatter()
    nf.numberStyle = .decimal
    nf.minimumIntegerDigits = 1
    nf.minimumFractionDigits = 3
    nf.maximumFractionDigits = 3
    nf.positivePrefix = " "
    nf.paddingCharacter = "0"
    nf.paddingPosition = .afterSuffix
    return nf
}()

public extension BSQuaternion {
    fileprivate var nf: NumberFormatter { quaternionNumberFormatter }
    var strings: [String] {
        [
            "w:\(nf.string(for: vector.w)!)",
            "x:\(nf.string(for: vector.x)!)",
            "y:\(nf.string(for: vector.y)!)",
            "z:\(nf.string(for: vector.z)!)",
        ]
    }

    var string: String {
        strings.joined(separator: isWatch ? "\n" : ", ")
    }

    var array: [Double] {
        [vector.x, vector.y, vector.z, vector.w]
    }
}

public extension Array where Element == BSActivityFlag {
    var string: String {
        map { $0.name }.joined(separator: ", ")
    }
}
