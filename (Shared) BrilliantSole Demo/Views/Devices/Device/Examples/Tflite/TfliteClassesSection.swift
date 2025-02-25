//
//  TfliteClassesSection.swift
//  BrilliantSoleSwiftDemo
//
//  Created by Zack Qattan on 2/24/25.
//

import BrilliantSole
import Combine
import SwiftUI

struct TfliteClassesSection: View {
    let device: BSDevice
    @Binding var selectedModelMode: TfliteModelMode
    @EnvironmentObject var tfliteFileState: TfliteFileState

    @State private var isTfliteInferencingEnabled = false

    var canEdit: Bool {
        !isWatch && !isTv && selectedModelMode == .custom
    }

    @State private var numberOfClasses: Int = 0
    let maxNumberOfClasses = 6
    @State private var classes: [String] = []

    var body: some View {
        Section {
            if canEdit {
                Group {
                    Picker("__Number of Classes__", selection: $numberOfClasses) {
                        ForEach(0 ... maxNumberOfClasses, id: \.self) { number in
                            Text("\(number)")
                                .tag(number)
                        }
                    }

                    ForEach(0 ..< classes.count, id: \.self) { index in
                        TextField("class \(index + 1)", text: $classes[index])
                    }
                    .onMove { indexSet, offset in
                        classes.move(fromOffsets: indexSet, toOffset: offset)
                    }
                    .onDelete { indexSet in
                        classes.remove(atOffsets: indexSet)
                        numberOfClasses -= 1
                    }
                }
                .disabled(isTfliteInferencingEnabled)
            } else {
                Text("__Classes:__ \(tapStompKickTfliteModel.classes!.joined(separator: ", "))")
            }
        } header: {
            Text("Classes")
        }
        .onAppear {
            if let classes = tfliteFileState.tfliteFile.classes {
                self.numberOfClasses = classes.count
            }
        }
        .onChange(of: numberOfClasses) { _, numberOfClasses in
            if numberOfClasses > classes.count {
                let newClasses = (classes.count + 1 ... numberOfClasses).map { "class \($0)" }
                classes.append(contentsOf: newClasses)
            } else if numberOfClasses < classes.count {
                classes.removeLast(classes.count - numberOfClasses)
            }
        }
        .onChange(of: classes) { _, classes in
            tfliteFileState.tfliteFile.classes = classes
        }
    }
}

#Preview {
    @Previewable @StateObject var tfliteFileState = TfliteFileState()
    @Previewable @State var selectedModelMode: TfliteModelMode = .custom

    List {
        TfliteClassesSection(device: .mock, selectedModelMode: $selectedModelMode)
    }
    .environmentObject(tfliteFileState)
    #if os(macOS)
        .frame(maxWidth: 350, minHeight: 300)
    #endif
}
