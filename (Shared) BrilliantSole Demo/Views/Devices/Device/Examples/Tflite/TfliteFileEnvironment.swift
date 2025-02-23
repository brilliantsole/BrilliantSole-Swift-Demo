//
//  TfliteFileEnvironment.swift
//  BrilliantSoleSwiftDemo
//
//  Created by Zack Qattan on 2/22/25.
//

import BrilliantSole
import SwiftUI

class TfliteFileState: ObservableObject {
    @Published var tfliteFile: BSTfliteFile

    init(_ tfliteFile: BSTfliteFile = .init()) {
        self.tfliteFile = tfliteFile
    }
}
