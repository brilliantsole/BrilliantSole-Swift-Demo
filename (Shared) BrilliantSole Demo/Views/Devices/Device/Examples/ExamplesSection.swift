//
//  ExamplesSection.swift
//  BrilliantSoleSwiftDemo
//
//  Created by Zack Qattan on 2/18/25.
//

import BrilliantSole
import SwiftUI

struct ExamplesSection: View {
    let device: BSDevice

    @State private var selectedExample: Example?

    var body: some View {
        Section {
            ForEach(Example.allCases) { example in
                if example.worksWith(device: device) {
                    NavigationLink(destination: example.view(device: device),
                                   tag: example,
                                   selection: $selectedExample)
                    {
                        Text(example.name)
                    }
                }
            }

        } header: {
            Text("Examples")
                .font(.headline)
        }
    }
}

#Preview {
    NavigationStack {
        List {
            ExamplesSection(device: .mock)
        }
        .navigationDestination(for: Example.self) { deviceDemo in
            deviceDemo.view(device: .mock)
        }
    }
    #if os(macOS)
    .frame(maxWidth: 350, maxHeight: 300)
    #endif
}
