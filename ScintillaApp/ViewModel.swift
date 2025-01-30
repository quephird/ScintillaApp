//
//  ViewModel.swift
//  ScintillaApp
//
//  Created by Danielle Kefford on 1/29/25.
//

import SwiftUI

import ScintillaLib

@MainActor
class ViewModel: ObservableObject {
    @Published var renderedImage: CGImage?

    public func renderImage(source: String) async throws {
        let evaluator = Evaluator()
        let world = try evaluator.interpret(source: source)
        let canvas = await world.render(updateClosure: updateProgress)
        self.renderedImage = canvas.toCGImage()
    }

    private func updateProgress(_ percentRendered: Double, elapsedTime: Range<Date>) {
        // TODO: Need to implement this!!!
    }

    // TODO: This is tooooooootally temporary code just to verify that
    // it is possible to save the displayed image to the file system.
    // Until I figure out how to wire up a file dialog box, the path
    // to the file is hardcoded here.
    public func saveImage() throws {
        if let renderedImage {
            let ciContext = CIContext()
            let ciImage = CIImage(cgImage: renderedImage)

            let downloadsDir = FileManager.default.urls(for: .downloadsDirectory, in: .userDomainMask).first!
            let fileUrl = downloadsDir.appending(path: "test.png")

            try ciContext.writePNGRepresentation(
                of: ciImage,
                to: fileUrl,
                format: .RGBA8,
                colorSpace: ciImage.colorSpace!)
        }
    }
}
