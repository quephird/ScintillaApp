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
        AttributedTextEditor(text: $attributedCode, highlighter: highlighteCode)
    }
}

extension CodeEditor {
    public func highlighteCode(textStorage: NSTextStorage) {
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
        let cameraKeyword = /Camera/
        let lightKeywords = /AreaLight|PointLight/
        let shapeKeywords = /ParametricSurface|Plane/
        let regexColorMappings: [(Regex<Substring>, NSColor)] = [
            (cameraKeyword, #colorLiteral(red: 0, green: 0.8409650922, blue: 1, alpha: 1)),
            (lightKeywords, #colorLiteral(red: 0, green: 1, blue: 0.8250406384, alpha: 1)),
            (shapeKeywords, #colorLiteral(red: 0, green: 1, blue: 0.5444420576, alpha: 1)),
        ]

        for (regex, color) in regexColorMappings {
            self.highlight(textStorage: textStorage, regex: regex, color: color)
        }
    }

    private func highlightParameterNames(textStorage: NSTextStorage) {
        let parameterNameRegex = /\p{ID_Start}\p{ID_Continue}*(?=\s*:)/
        self.highlight(textStorage: textStorage, regex: parameterNameRegex, color: #colorLiteral(red: 0, green: 0.4649228454, blue: 0.5589954257, alpha: 1))
    }

    private func highlightNumbers(textStorage: NSTextStorage) {
        let numberRegex = /-?(\d+.)?\d+/
        self.highlight(textStorage: textStorage, regex: numberRegex, color: #colorLiteral(red: 1, green: 0.9946382642, blue: 0.3478766382, alpha: 1))
    }

    private func highlightMethodNames(textStorage: NSTextStorage) {
        let methodAttributes: [NSAttributedString.Key: Any] = [.foregroundColor: #colorLiteral(red: 0.1923640966, green: 0.5559594035, blue: 0.3243826628, alpha: 1)]
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
        self.highlight(textStorage: textStorage, regex: punctuationRegex, color: #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1))
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
