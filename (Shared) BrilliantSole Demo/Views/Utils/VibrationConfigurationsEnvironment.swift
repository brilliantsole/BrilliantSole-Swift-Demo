//
//  VibrationConfigurationsEnvironment.swift
//  BrilliantSoleSwiftDemo
//
//  Created by Zack Qattan on 2/22/25.
//

import BrilliantSole
import SwiftUI

class VibrationConfigurationsState: ObservableObject {
    @Published var configurations: BSVibrationConfigurations

    init(_ configurations: BSVibrationConfigurations = .init()) {
        self.configurations = configurations
    }
}
