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

    init() {
        UserDefaults.standard.set(false, forKey: "NSAutomaticPeriodSubstitutionEnabled")
    }

    var currentErrorMessage: String {
        if let viewModel {
            if let error = viewModel.currentEvaluatorError {
                return "\(error)"
            }
        }

        return ""
    }

    var body: some Scene {
        DocumentGroup(newDocument: ScintillaDocument()) { file in
            ContentView(document: file.$document)
                .focusedSceneValue(\.document, file.$document)
            HStack {
                Text(currentErrorMessage)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)
            }
        }
        .commands {
            CommandMenu("Editor") {
                Button("Comment Selection") {
                    NSApplication.shared.sendAction(#selector(AttributedTextView.commentLines(_:)), to: nil, from: self)
                }
                .keyboardShortcut("/")
            }

            CommandGroup(after: .saveItem) {
                Divider()

                Button("Render Scene…") {
                    if let document, let viewModel {
                        Task {
                            do {
                                viewModel.currentEvaluatorError = nil
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
