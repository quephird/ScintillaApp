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

    public func saveImage(fileUrl: URL) throws {
        if let renderedImage {
            let ciContext = CIContext()
            let ciImage = CIImage(cgImage: renderedImage)

            try ciContext.writePNGRepresentation(
                of: ciImage,
                to: fileUrl,
                format: .RGBA8,
                colorSpace: ciImage.colorSpace!)
        }
    }
}
