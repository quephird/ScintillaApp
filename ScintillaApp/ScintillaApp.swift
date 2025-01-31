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
    @FocusedBinding(\.viewModel) var viewModel: ViewModel?

    var body: some Scene {
        DocumentGroup(newDocument: ScintillaDocument()) { file in
            ContentView(document: file.$document)
                .focusedSceneValue(\.document, file.$document)
        }
        .commands {
            CommandGroup(after: .saveItem) {
                Divider()

                Button("Render Scene…") {
                    if let document, let viewModel {
                        Task {
                            viewModel.showSheet = true
                            // TODO: BLARGG... we need to surface errors in the UI here!
                            do {
                                try await viewModel.renderImage(source: document.text)
                            } catch {
                                print(error)
                            }
                        }
                    }
                }
                .disabled(document == nil)
                .keyboardShortcut("R")

                Button("Export Image…") {
                    viewModel!.showFileExporter = true
                }
                .disabled(viewModel?.renderedImage == nil)
                .keyboardShortcut("E")
            }
        }
    }
}
