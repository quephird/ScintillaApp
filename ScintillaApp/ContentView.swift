//
//  ContentView.swift
//  ScintillaApp
//
//  Created by Danielle Kefford on 1/17/25.
//

import SwiftUI

struct ContentView: View {
    @Binding var document: ScintillaDocument
    @State var renderedImage: CGImage?

    var body: some View {
        VStack {
            CodeEditor(code: $document.text)
        }
        .sheet(item: $renderedImage) { renderedImage in
            let size = NSSize(width: renderedImage.width, height: renderedImage.height)
            VStack {
                Image(nsImage: NSImage(cgImage: renderedImage, size: size))
                Button("Dismiss") {
                    self.renderedImage = nil
                }
            }
        }
        .padding()
        .focusedSceneValue(\.renderedImage, $renderedImage)
    }
}

extension CGImage: @retroactive Identifiable {
    public var id: ObjectIdentifier {
        ObjectIdentifier(self)
    }
}
