//
//  ViewModel.swift
//  ScintillaApp
//
//  Created by Danielle Kefford on 1/29/25.
//

import SwiftUI

import ScintillaLib

@MainActor
@Observable
class ViewModel {
    var showSheet: Bool = false
    var currentEvaluatorError: Error?
    var showFileExporter: Bool = false
    var renderedImage: CGImage?

    var percentRendered: Double = 0.0
    var elapsedTime: Range<Date> = Date()..<Date()

    public func renderImage(source: String) async throws {
        let evaluator = Evaluator()
        do {
            let world = try evaluator.interpret(source: source)
            self.showSheet = true
            let canvas = await world.render(updateClosure: updateProgress)
            self.renderedImage = canvas.toCGImage()
        } catch {
            self.currentEvaluatorError = error
        }
    }

    private func updateProgress(_ percentRendered: Double, elapsedTime: Range<Date>) {
        self.percentRendered = percentRendered
        self.elapsedTime = elapsedTime
    }
}
