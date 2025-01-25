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
            var tokenizer = Tokenizer(source: document.text)
            do {
                let tokens = try tokenizer.scanTokens()
                var parser = Parser(tokens: tokens)
                let statements = try parser.parse()
                for statement in statements {
                    print(statement)
                }
            } catch {
                print(error)
            }
        }
    }
}
