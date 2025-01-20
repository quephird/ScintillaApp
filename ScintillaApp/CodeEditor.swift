//
//  CodeEditor.swift
//  ScintillaApp
//
//  Created by Danielle Kefford on 1/18/25.
//

import SwiftUI

struct CodeEditor: View {
    @Binding var attributedCode: NSAttributedString

    public init(code: Binding<String>) {
        self._attributedCode = Binding<NSAttributedString>(
            get: { return NSAttributedString(string: code.wrappedValue) },
            set: { attributedCode in
                code.wrappedValue = attributedCode.string
            }
        )
    }

    var body: some View {
        AttributedTextEditor(text: $attributedCode)
    }
}
