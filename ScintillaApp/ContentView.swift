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
        .sheet(isPresented: $viewModel.showSheet) {
            RenderedImageView(viewModel: viewModel)
        }
        .padding()
    }
}
