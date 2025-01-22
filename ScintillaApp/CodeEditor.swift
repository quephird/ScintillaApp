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
        AttributedTextEditor(text: $attributedCode, highlighter: codeHighlighter)
    }

    public func codeHighlighter(textStorage: NSTextStorage) {
        let code = textStorage.string

        let cameraKeyword = ["Camera"]
        let lightKeywords = ["AreaLight", "PointLight"]
        let shapeKeywords = ["ParametricSurface", "Plane"]
        let keywordColorMappings: [[String]: NSColor] = [
            cameraKeyword: #colorLiteral(red: 0, green: 0.8409650922, blue: 1, alpha: 1),
            lightKeywords: #colorLiteral(red: 0, green: 1, blue: 0.8250406384, alpha: 1),
            shapeKeywords: #colorLiteral(red: 0, green: 1, blue: 0.5444420576, alpha: 1),
        ]

        for (keywords, color) in keywordColorMappings {
            for keyword in keywords {
                let attributes: [NSAttributedString.Key: Any] = [.foregroundColor: color]
                let ranges = code.ranges(of: keyword)
                for range in ranges {
                    let nsRange = NSRange(range, in: code)
                    textStorage.addAttributes(attributes, range: nsRange)
                }
            }
        }

        let paramAttributes: [NSAttributedString.Key: Any] = [.foregroundColor: #colorLiteral(red: 0, green: 0.4649228454, blue: 0.5589954257, alpha: 1)]
        let paramNameRegex = /\p{ID_Start}\p{ID_Continue}*(?=\s*:)/
        let paramRanges = code.ranges(of: paramNameRegex)
        for range in paramRanges {
            let nsRange = NSRange(range, in: code)
            textStorage.addAttributes(paramAttributes, range: nsRange)
        }

        let numberAttributes: [NSAttributedString.Key: Any] = [.foregroundColor: #colorLiteral(red: 1, green: 0.9946382642, blue: 0.3478766382, alpha: 1)]
        let numberRegex = /-?(\d+.)?\d+/
        let numberRanges = code.ranges(of: numberRegex)
        for range in numberRanges {
            let nsRange = NSRange(range, in: code)
            textStorage.addAttributes(numberAttributes, range: nsRange)
        }

        let methodAttributes: [NSAttributedString.Key: Any] = [.foregroundColor: #colorLiteral(red: 0.1923640966, green: 0.5559594035, blue: 0.3243826628, alpha: 1)]
        let methodRegex = /\.(?<method>\p{ID_Start}\p{ID_Continue}*)/
        let methodMatches = code.matches(of: methodRegex)
        for match in methodMatches {
            let swiftRange = match.method.startIndex ..< match.method.endIndex
            let nsRange = NSRange(swiftRange, in: code)
            textStorage.addAttributes(methodAttributes, range: nsRange)
        }

        let punctuationAttributes: [NSAttributedString.Key: Any] = [.foregroundColor: #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)]
        let punctuationRegex = /\.|:|\(|\)|\{|\}|,/
        let punctuationRanges = code.ranges(of: punctuationRegex)
        for range in punctuationRanges {
            let nsRange = NSRange(range, in: code)
            textStorage.addAttributes(punctuationAttributes, range: nsRange)
        }
    }
}
