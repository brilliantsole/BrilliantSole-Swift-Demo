//
//  GenericDeviceRowHeader.swift
//  BrilliantSoleSwiftDemo
//
//  Created by Zack Qattan on 2/14/25.
//

import SwiftUI

import BrilliantSole
import SwiftUI

struct GenericDeviceRowHeader: View {
    let name: String
    let deviceType: BSDeviceType?

    var deviceTypeSystemImage: String? {
        switch deviceType {
        case .leftInsole, .rightInsole:
            "shoe"
        case nil:
            nil
        }
    }

    var body: some View {
        VStack(alignment: isWatch ? .center : .leading) {
            Text(name)
                .font(.title2)
                .bold()

            if let deviceType {
                HStack(spacing: 4) {
                    Image(systemName: deviceTypeSystemImage!)
                        .modify {
                            if deviceType == .leftInsole {
                                $0.scaleEffect(x: -1)
                            }
                        }
                    Text(deviceType.name)
                }
            }
        }
    }
}

#Preview {
    GenericDeviceRowHeader(name: "my device", deviceType: .leftInsole)
    #if os(macOS)
        .frame(maxWidth: 350, minHeight: 300)
    #endif
}
