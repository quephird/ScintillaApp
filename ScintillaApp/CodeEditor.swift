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
        AttributedTextEditor(text: $attributedCode, highlighter: highlightCode)
    }
}

extension CodeEditor {
    public func highlightCode(textStorage: NSTextStorage) {
        let highlighters: [(NSTextStorage) -> Void] = [
            self.highlightKeywords,
            self.highlightParameterNames,
            self.highlightNumbers,
            self.highlightMethodNames,
            self.highlightPunctuation,
        ]

        for highlighter in highlighters {
            highlighter(textStorage)
        }
    }

    private func highlightKeywords(textStorage: NSTextStorage) {
        // TODO: Need to build these regexes dynamically somehow from ScintillaBuiltin!
        let cameraKeyword = /Camera/
        let lightKeywords = /AreaLight|PointLight/
        let shapeKeywords = /ParametricSurface|Plane|Cube|Sphere/
        let regexColorMappings: [(Regex<Substring>, NSColor)] = [
            (cameraKeyword, NSColor(named: "CameraKeyword")!),
            (lightKeywords, NSColor(named: "LightKeyword")!),
            (shapeKeywords, NSColor(named: "ShapeKeyword")!),
        ]

        for (regex, color) in regexColorMappings {
            self.highlight(textStorage: textStorage, regex: regex, color: color)
        }
    }

    private func highlightParameterNames(textStorage: NSTextStorage) {
        let parameterNameRegex = /\p{ID_Start}\p{ID_Continue}*(?=\s*:)/
        self.highlight(textStorage: textStorage,
                       regex: parameterNameRegex,
                       color: NSColor(named: "ParameterName")!)
    }

    private func highlightNumbers(textStorage: NSTextStorage) {
        let numberRegex = /-?(\d+.)?\d+/
        self.highlight(textStorage: textStorage,
                       regex: numberRegex,
                       color: NSColor(named: "Number")!)
    }

    private func highlightMethodNames(textStorage: NSTextStorage) {
        let methodAttributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: NSColor(named: "MethodName")!,
        ]
        let methodRegex = /\.(?<method>\p{ID_Start}\p{ID_Continue}*)/
        let methodMatches = textStorage.string.matches(of: methodRegex)
        for match in methodMatches {
            let swiftRange = match.method.startIndex ..< match.method.endIndex
            let nsRange = NSRange(swiftRange, in: textStorage.string)
            textStorage.addAttributes(methodAttributes, range: nsRange)
        }
    }

    private func highlightPunctuation(textStorage: NSTextStorage) {
        let punctuationRegex = /\.|:|\(|\)|\{|\}|,/
        self.highlight(textStorage: textStorage,
                       regex: punctuationRegex,
                       color: NSColor(named: "Punctuation")!)
    }

    private func highlight<T>(textStorage: NSTextStorage,
                              regex: Regex<T>,
                              color: NSColor) {
        let punctuationAttributes: [NSAttributedString.Key: Any] = [.foregroundColor: color]
        let punctuationRanges = textStorage.string.ranges(of: regex)
        for range in punctuationRanges {
            let nsRange = NSRange(range, in: textStorage.string)
            textStorage.addAttributes(punctuationAttributes, range: nsRange)
        }
    }
}
