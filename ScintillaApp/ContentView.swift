//
//  ContentView.swift
//  ScintillaApp
//
//  Created by Danielle Kefford on 1/17/25.
//

import SwiftUI

struct ContentView: View {
    @Binding var document: ScintillaDocument
    @ObservedObject var viewModel: ViewModel

    var body: some View {
        VStack {
            CodeEditor(code: $document.text)
        }
        .sheet(item: $viewModel.renderedImage) { renderedImage in
            let size = NSSize(width: renderedImage.width, height: renderedImage.height)
            VStack {
                Image(nsImage: NSImage(cgImage: renderedImage, size: size))
                Button("Dismiss") {
                    self.viewModel.renderedImage = nil
                }
            }
        }
        .padding()
    }
}
