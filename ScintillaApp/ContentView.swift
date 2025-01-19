//
//  ContentView.swift
//  ScintillaApp
//
//  Created by Danielle Kefford on 1/17/25.
//

import SwiftUI

struct ContentView: View {
    @Binding var document: ScintillaDocument
    @State var text: NSAttributedString = NSAttributedString(string: "This is a test")

    var body: some View {
        VStack {
            AttributedTextEditor(text: $text)
        }
        .padding()
    }
}
