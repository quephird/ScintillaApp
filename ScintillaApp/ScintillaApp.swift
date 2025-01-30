//
//  ScintillaApp.swift
//  ScintillaApp
//
//  Created by Danielle Kefford on 1/17/25.
//

import SwiftUI
import UniformTypeIdentifiers

@main
struct ScintillaApp: App {
    @FocusedBinding(\.document) var document: ScintillaDocument?
    @StateObject var viewModel = ViewModel()

    var body: some Scene {
        DocumentGroup(newDocument: ScintillaDocument()) { file in
            ContentView(document: file.$document, viewModel: viewModel)
                .focusedSceneValue(\.document, file.$document)
        }
        .commands {
            CommandGroup(after: .saveItem) {
                Divider()
                Button("Render Scene") {
                    if let document {
                        Task {
                            viewModel.showSheet = true
                            try await viewModel.renderImage(source: document.text)
                        }
                    }
                }
                .disabled(document == nil)
                .keyboardShortcut("R")
                Button("Save Image") {
                    do {
                        try viewModel.saveImage()
                    } catch {
                        // TODO: Need to surface error in the UI somehow
                        print(error)
                    }
                }
                .disabled(viewModel.renderedImage == nil)
            }
        }
    }
}
