//
//  URLUtils.swift
//  BrilliantSoleSwiftDemo
//
//  Created by Zack Qattan on 3/1/25.
//

import Foundation

extension URL {
    var isDeeplink: Bool {
        // matches brilliantsole-demo://<rest-of-the-url>
        return scheme == "brilliantsole-demo"
    }
}
