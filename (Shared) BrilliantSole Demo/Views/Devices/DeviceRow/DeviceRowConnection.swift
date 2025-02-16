//
//  DeviceRowConnection.swift
//  BrilliantSoleSwiftDemo
//
//  Created by Zack Qattan on 2/13/25.
//

import BrilliantSole
import SwiftUI

struct DeviceRowConnection: View {
    let connectable: BSConnectable

    var body: some View {
        HStack {
            ConnectableButton(connectable: connectable, includeConnectionType: true)
            Spacer()
        }
    }
}

#Preview {
    DeviceRowConnection(connectable: BSDevice.mock)
    #if os(macOS)
        .frame(maxWidth: 350, minHeight: 300)
    #endif
}
