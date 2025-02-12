//
//  WidgetViewModifier.swift
//  BrilliantSoleSwiftDemo
//
//  Created by Zack Qattan on 2/10/25.
//

public extension WidgetConfiguration {
    func modify<Content>(_ transform: (Self) -> Content) -> Content {
        transform(self)
    }
}
