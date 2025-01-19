//
//  ScintillaAppApp.swift
//  ScintillaApp
//
//  Created by Danielle Kefford on 1/17/25.
//

import SwiftUI
import UniformTypeIdentifiers

@main
struct ScintillaApp: App {
    @State private var showOpenFileDialog = false
    @State private var showAlert = false
    @State private var errorMessage = ""

    @State private var fileContents: String = "This is a test"

    var body: some Scene {
        WindowGroup {
            ContentView(fileContents: $fileContents)
                .alert(errorMessage, isPresented: $showAlert, actions: {})
        }
        .commands {
            CommandGroup(replacing: .newItem) {
                Button("Open file...") {
                    self.showOpenFileDialog = true
                }
                .keyboardShortcut("o", modifiers: .command)
                .fileImporter(
                    isPresented: $showOpenFileDialog,
                    allowedContentTypes: [.scintillaDocument],
                    allowsMultipleSelection: false
                ) { result in
                    do {
                        guard let fileUrl = try result.get().first else {
                            throw ScintillaError.fileCouldNotBeSelected
                        }

                        guard fileUrl.startAccessingSecurityScopedResource() else {
                            throw ScintillaError.fileCouldNotBeOpened
                        }

                        try self.openFile(fileUrl: fileUrl)
                    }
                    catch {
                        self.errorMessage = error.localizedDescription
                    }
                }
            }
        }
    }

    private func openFile(fileUrl: URL) throws {
        let fileData: Data = try Data(contentsOf: fileUrl)
        if let fileContents = String(data: fileData, encoding: .utf8) {
            self.fileContents = fileContents
        }
    }
}
