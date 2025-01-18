//
//  ContentView.swift
//  ScintillaApp
//
//  Created by Danielle Kefford on 1/17/25.
//

import SwiftUI

struct ContentView: View {
    @State private var fileContents: String = "This is a test"

    var body: some View {
        VStack {
            TextEditor(text: $fileContents)
                .font(.system(size: 14, design: .monospaced))
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
