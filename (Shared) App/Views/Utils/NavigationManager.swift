//
//  NavigationManager.swift
//  BrilliantSoleSwiftDemo
//
//  Created by Zack Qattan on 2/11/25.
//

import SwiftUI

class NavigationManager: ObservableObject {
    @Published var path = NavigationPath()

    func navigateTo<T: Hashable>(_ destination: T) {
        path.append(destination)
    }

    func goBack() {
        if !path.isEmpty {
            path.removeLast()
        }
    }

    func resetNavigation() {
        path = NavigationPath()
    }
}
