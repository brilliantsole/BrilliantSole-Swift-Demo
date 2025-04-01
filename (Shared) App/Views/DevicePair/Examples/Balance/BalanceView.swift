//
//  BalanceView.swift
//  BrilliantSoleSwiftDemo
//
//  Created by Zack Qattan on 2/27/25.
//

import BrilliantSole
import Combine
import simd
import SwiftUI

struct BalanceView: View {
    let centerOfPressureProvider: BSCenterOfPressureProvider

    @State private var isInsideTarget = false {
        didSet {
            if isInsideTarget != oldValue {
                if isInsideTarget {
                    firstTimeInsideTarget = .now
                }
            }
        }
    }

    @State private var centerOfPressure: BSCenterOfPressure = .init() {
        didSet {
            if isPlayingGame {
                let newIsInsideTarget = targetRange.contains(centerOfPressure.x)
                if newIsInsideTarget != isInsideTarget {
                    isInsideTarget = newIsInsideTarget
                }
                else {
                    if isInsideTarget && timeInsideTarget > timePerTarget {
                        resetTarget()
                    }
                }
            }
        }
    }

    @State private var firstTimeInsideTarget: Date = .now
    private let timePerTarget: Double = 2
    private var timeInsideTarget: TimeInterval { -firstTimeInsideTarget.timeIntervalSinceNow }
    private var timeInterpolation: Double { timeInsideTarget / timePerTarget }

    @State private var isPlayingGame = false
    func toggleGame() {
        isPlayingGame.toggle()
        if isPlayingGame {
            resetTarget()
        }
    }

    @State private var targetPosition: Double = .zero
    @State private var targetDiameter: Double = .zero
    private var targetRadius: Double { targetDiameter / 2 }
    @State private var targetRange: ClosedRange<Double> = 0.0 ... 1.0
    func resetTarget() {
        firstTimeInsideTarget = .now

        targetDiameter = .random(in: 0.1 ... 0.2)
        targetPosition = .random(in: targetRadius ... 1 - targetRadius)
        targetRange = targetPosition - targetRadius ... targetPosition + targetRadius
    }

    private let cornerRadius: CGFloat = 10.0
    func verticalBar(geometry: GeometryProxy, side: BSSide) -> some View {
        ZStack(alignment: .bottom) {
            let barWidth = geometry.size.width * 0.15
            RoundedRectangle(cornerRadius: cornerRadius)
                .fill(.red)
                .frame(width: barWidth)
                .frame(height: geometry.size.height * (side == .left ? 1 - centerOfPressure.x : centerOfPressure.x))
            RoundedRectangle(cornerRadius: cornerRadius)
                .stroke(.black, lineWidth: 3)
                .frame(height: geometry.size.height)
                .frame(width: barWidth)

            let targetHeight = geometry.size.height * targetDiameter
            let targetOffset = -geometry.size.height * (side == .left ? 1 - targetPosition : targetPosition)
            ZStack {
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(isInsideTarget ? .green : .yellow)
                    .opacity(0.5)
                if isInsideTarget {
                    GeometryReader { geometry in
                        RoundedRectangle(cornerRadius: cornerRadius)
                            .stroke(.blue, lineWidth: 3)
                            .frame(width: geometry.size.width * (1 - timeInterpolation), height: geometry.size.height * (1 - timeInterpolation), alignment: .center)
                            .position(
                                x: geometry.size.width * 0.5,
                                y: geometry.size.height * 0.5
                            )
                    }
                }
            }
            .frame(width: geometry.size.width * 0.2)
            .frame(height: targetHeight)
            .offset(y: targetOffset + (targetHeight / 2))
            .modify {
                if !isPlayingGame {
                    $0.hidden()
                }
            }
        }
    }

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                RoundedRectangle(cornerRadius: 15.0)
                    .fill(.white)
                HStack(spacing: geometry.size.width * 0.2) {
                    verticalBar(geometry: geometry, side: .left)
                    verticalBar(geometry: geometry, side: .right)
                }
                .frame(width: geometry.size.width - 10, height: geometry.size.height - 10)
            }
        }
        .padding(10)
        .onReceive(centerOfPressureProvider.centerOfPressurePublisher) {
            centerOfPressure = $0.normalizedCenterOfPressure
        }
        .toolbar {
            let recalibrateButton = Button {
                centerOfPressureProvider.resetPressure()
            } label: {
                Image(systemName: "arrow.counterclockwise")
                    .accessibilityLabel("recalibrate pressure")
            }
            let toggleGameButton = Button {
                toggleGame()
            } label: {
                Image(systemName: isPlayingGame ? "stop.fill" : "play.fill")
                    .accessibilityLabel(isPlayingGame ? "stop game" : "start game")
            }
            #if os(watchOS)
                ToolbarItem(placement: .topBarTrailing) {
                    recalibrateButton
                        .foregroundColor(.primary)
                }
                ToolbarItem(placement: .bottomBar) {
                    toggleGameButton
                        .foregroundColor(.primary)
                }
            #else
                ToolbarItem {
                    recalibrateButton
                }
                ToolbarItem {
                    toggleGameButton
                }
            #endif
        }
    }
}

#Preview {
    NavigationStack {
        BalanceView(centerOfPressureProvider: BSDevicePair.insoles)
    }
    #if os(macOS)
    .frame(maxWidth: 350, minHeight: 300)
    #endif
}
