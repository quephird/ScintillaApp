//
//  ContentView.swift
//  ScintillaApp
//
//  Created by Danielle Kefford on 1/17/25.
//

import SwiftUI

struct ContentView: View {
    @Binding var document: ScintillaDocument

    var body: some View {
        VStack {
            TextEditor(text: $document.text)
                .font(.system(size: 14, design: .monospaced))
        }
        .padding()
    }
}
