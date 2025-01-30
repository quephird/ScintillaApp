//
//  RenderedImageView.swift
//  ScintillaApp
//
//  Created by Danielle Kefford on 1/29/25.
//

import SwiftUI

struct RenderedImageView: View {
    @ObservedObject var viewModel: ViewModel

    var body: some View {
        if let renderedImage = viewModel.renderedImage {
            VStack {
                Image(nsImage: NSImage(cgImage: renderedImage, size: renderedImage.nsSize))
                Button("Dismiss") {
                    self.viewModel.showSheet = false
                    self.viewModel.renderedImage = nil
                }
            }
        } else {
            VStack {
                Spacer()
                ProgressView(value: viewModel.percentRendered) {
                    Text("Rendering…")
                } currentValueLabel: {
                    Text(
                        viewModel.percentRendered
                            .formatted(
                                .percent.precision(
                                    .integerAndFractionLength(integerLimits: 1...3,
                                                              fractionLimits: 0...0))))
                }
                    .progressViewStyle(.circular)
                Spacer()
            }
        }
        HStack {
            Text("Elapsed time: \(viewModel.elapsedTime.formatted(.components(style: .condensedAbbreviated)))")
                .padding(.leading, 5)
                .padding(.bottom, 5)
            Spacer()
        }
    }
}
