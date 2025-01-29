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

    @State var percentRendered: Double = 0.0
    @State var elapsedTime: Range<Date> = Date()..<Date()

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
                            try await viewModel.renderImage(source: document.text)
                        }
                    }
                }
                .disabled(document == nil)
                .keyboardShortcut("R")
                Button("Save Image") {
                    if let _ = viewModel.renderedImage {
                        // TODO: This is tooooooootally temporary code just to verify
                        // that I can generate any sort of image whatsoever and be able
                        // to view it
                        let downloadsDir = FileManager.default.urls(for: .downloadsDirectory, in: .userDomainMask).first!
                        let fileUrl = downloadsDir.appending(path: "test.png")
                        do {
                            try viewModel.saveImage(fileUrl: fileUrl)
                        } catch {
                            print(error)
                        }
                    }
                }
                .disabled(document == nil)
            }
        }
    }
}
