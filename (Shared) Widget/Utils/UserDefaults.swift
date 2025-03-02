//
//  UserDefaults.swift
//  BrilliantSoleSwiftDemo
//
//  Created by Zack Qattan on 3/1/25.
//

import Foundation

let teamId: String = "KT7J75V2U8"

func getUserDefaults(_ string: String) -> UserDefaults? {
    if isMacOs {
        return .init(suiteName: "\(teamId).com.demo.\(string)")
    }
    else {
        return .init(suiteName: "group.com.brilliantsole.demo.\(string)")
    }
}
