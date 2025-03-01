//
//  UserDefaults.swift
//  BrilliantSoleSwiftDemo
//
//  Created by Zack Qattan on 3/1/25.
//

import Foundation

let teamId: String = "KT7J75V2U8"

func getUserDefaults(_ string: String) -> UserDefaults? {
    .init(suiteName: "\(teamId).com.demo.\(string)")
}
