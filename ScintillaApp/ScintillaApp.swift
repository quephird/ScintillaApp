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
    @FocusedBinding(\.renderedImage) var renderedImage: CGImage??

    @State var percentRendered: Double = 0.0
    @State var elapsedTime: Range<Date> = Date()..<Date()

    var body: some Scene {
        DocumentGroup(newDocument: ScintillaDocument()) { file in
            ContentView(document: file.$document)
                .focusedSceneValue(\.document, file.$document)
        }
        .commands {
            CommandGroup(after: .saveItem) {
                Divider()
                Button("Render Scene") {
                    Task {
                        await self.renderScene()
                    }
                }
                .disabled(document == nil)
                .keyboardShortcut("R")
            }
        }
    }

    private func renderScene() async {
        if let document {
            do {
                let evaluator = Evaluator()
                let world = try evaluator.interpret(source: document.text)
                let canvas = await world.render(updateClosure: updateProgress)

                // TODO: This is tooooooootally temporary code just to verify
                // that I can generate any sort of image whatsoever and be able
                // to view it
                let downloadsDir = FileManager.default.urls(for: .downloadsDirectory, in: .userDomainMask).first!
                let newFileUrl = downloadsDir.appending(path: "test.png")
                canvas.save(to: newFileUrl.path())

                let cgImage = canvas.toCGImage()
                self.renderedImage = cgImage
//                let ciContext = CIContext()
//                let ciImage = CIImage(cgImage: cgImage)
//
//                try ciContext.writePNGRepresentation(
//                    of: ciImage,
//                    to: newFileUrl,
//                    format: .RGBA8,
//                    colorSpace: ciImage.colorSpace!)
            } catch {
                // TODO: Need to expose error in app somehow
                print(error)
            }
        }
    }

    // TODO: Need to figure out what the closure passed to World.render()
    // should look like
    private func updateProgress(_ newPercentRendered: Double, newElapsedTime: Range<Date>) {
        self.percentRendered = newPercentRendered
        self.elapsedTime = newElapsedTime
    }
}
