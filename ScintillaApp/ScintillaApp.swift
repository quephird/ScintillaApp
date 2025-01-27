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

    var body: some Scene {
        DocumentGroup(newDocument: ScintillaDocument()) { file in
            ContentView(document: file.$document)
                .focusedSceneValue(\.document, file.$document)
        }
        .commands {
            CommandGroup(after: .saveItem) {
                Divider()
                Button("Render Scene") {
                    self.renderScene()
                }
                .disabled(document == nil)
                .keyboardShortcut("R")
            }
        }
    }

    private func renderScene() {
        print("Rendering scene...")
        if let document {
            do {
                let evaluator = Evaluator()
                try evaluator.interpret(source: document.text)
            } catch {
                // TODO: Need to expose error in app somehow
                print(error)
            }
        }
    }
}
