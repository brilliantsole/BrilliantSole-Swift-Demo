//
//  LoggerUtils.swift
//  BrilliantSoleSwiftDemo
//
//  Created by Zack Qattan on 2/28/25.
//

import OSLog

func getLogger(category: String, disabled: Bool = false) -> Logger? {
    disabled ? nil : Logger(subsystem: Bundle.main.bundleIdentifier ?? "", category: category)
}
