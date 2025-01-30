//
//  ContentView.swift
//  ScintillaApp
//
//  Created by Danielle Kefford on 1/17/25.
//

import SwiftUI

struct ContentView: View {
    @Binding var document: ScintillaDocument
    @State var viewModel: ViewModel = ViewModel()

    var body: some View {
        VStack {
            CodeEditor(code: $document.text)
        }
        .sheet(isPresented: $viewModel.showSheet) {
            RenderedImageView(viewModel: viewModel)
                .fileExporter(isPresented: $viewModel.showFileExporter,
                              item: viewModel.renderedImage) { result in
                    // TODO: Need to properly surface messages to UI
                    switch result {
                    case .success(let url):
                        print("Exported to \(url)")
                    case .failure(let error):
                        print("Failed to export: \(error)")
                    }
                }
        }
        .focusedSceneValue(\.viewModel, self.$viewModel)
        .padding()
    }
}
