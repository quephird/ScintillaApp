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
    public func highlightCode(layoutManager: NSLayoutManager) {
        let highlighters: [(NSLayoutManager) -> Void] = [
            self.highlightKeywords,
            self.highlightConstructors,
            self.highlightBuiltinFunctions,
            self.highlightBuiltinConstants,
            self.highlightParameterNames,
            self.highlightNumbers,
            self.highlightMethodNames,
            self.highlightPunctuation,
            self.highlightEndOfLineComments,
            self.highlightMultiLineComments,
        ]

        for highlighter in highlighters {
            highlighter(layoutManager)
        }
    }

    private func highlightConstructors(layoutManager: NSLayoutManager) {
        // TODO: Need to build these regexes dynamically somehow from ScintillaBuiltin!
        let worldKeyword = /\bWorld\b/
        let cameraKeyword = /\bCamera\b/
        let lightKeywords = /\b(?:AreaLight|PointLight|SpotLight)\b/
        let colorKeyword = /\bColor\b/
        let materialKeywords = /\b(?:Uniform|Striped|Checkered2D|Checkered3D|Gradient|ColorFunction)\b/
        let shapeKeywords = /\b(?:ParametricSurface|Plane|Cone|Cube|Cylinder|Group|ImplicitSurface|Prism|Sphere|Superellipsoid|SurfaceOfRevolution|Torus)\b/

        let regexes: [Regex<Substring>] = [
            worldKeyword,
            cameraKeyword,
            lightKeywords,
            colorKeyword,
            materialKeywords,
            shapeKeywords,
        ]

        for regex in regexes {
            self.highlight(layoutManager: layoutManager,
                           regex: regex,
                           color: NSColor(named: "Constructor")!)
        }
    }

    private func highlightBuiltinFunctions(layoutManager: NSLayoutManager) {
        let textStorage = layoutManager.textStorage!
        let methodAttributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: NSColor(named: "BuiltinFunction")!,
        ]
        let methodRegex = /\b(?<method>(?:sin|cos|tan|arcsin|arccos|arctan|arctan2|exp|log|min|max|abs|trunc|round)\()/
        let methodMatches = textStorage.string.matches(of: methodRegex)
        for match in methodMatches {
            let swiftRange = match.method.startIndex ..< match.method.endIndex
            let nsRange = NSRange(swiftRange, in: textStorage.string)
            layoutManager.setTemporaryAttributes(methodAttributes, forCharacterRange: nsRange)
        }
    }

    private func highlightBuiltinConstants(layoutManager: NSLayoutManager) {
        let regex = /\bpi\b/
        self.highlight(layoutManager: layoutManager,
                       regex: regex,
                       color: NSColor(named: "BuiltinFunction")!)
    }

    private func highlightKeywords(layoutManager: NSLayoutManager) {
        let languageKeywords = /\b(?:let|func|true|false|in)\b/
        let operators = /\+|\-|\*|\/|\^|=/
        let regexColorMappings: [(Regex<Substring>, NSColor)] = [
            (languageKeywords, NSColor(named: "LanguageKeyword")!),
            (operators, NSColor(named: "Operator")!),
        ]

        for (regex, color) in regexColorMappings {
            self.highlight(layoutManager: layoutManager, regex: regex, color: color)
        }
    }

    private func highlightParameterNames(layoutManager: NSLayoutManager) {
        let parameterNameRegex = /\p{ID_Start}\p{ID_Continue}*(?=\s*:)/
        self.highlight(layoutManager: layoutManager,
                       regex: parameterNameRegex,
                       color: NSColor(named: "ParameterName")!)
    }

    private func highlightNumbers(layoutManager: NSLayoutManager) {
        let numberRegex = /\b-?(\d+.)?\d+\b/
        self.highlight(layoutManager: layoutManager,
                       regex: numberRegex,
                       color: NSColor(named: "Number")!)
    }

    private func highlightMethodNames(layoutManager: NSLayoutManager) {
        let textStorage = layoutManager.textStorage!
        let methodAttributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: NSColor(named: "MethodName")!,
        ]
        let methodRegex = /\.(?<method>\p{ID_Start}\p{ID_Continue}*)/
        let methodMatches = textStorage.string.matches(of: methodRegex)
        for match in methodMatches {
            let swiftRange = match.method.startIndex ..< match.method.endIndex
            let nsRange = NSRange(swiftRange, in: textStorage.string)
            layoutManager.setTemporaryAttributes(methodAttributes, forCharacterRange: nsRange)
        }
    }

    private func highlightPunctuation(layoutManager: NSLayoutManager) {
        let punctuationRegex = /\.|:|\(|\)|\{|\}|\[|\]|,/
        self.highlight(layoutManager: layoutManager,
                       regex: punctuationRegex,
                       color: NSColor(named: "Punctuation")!)
    }

    private func highlightEndOfLineComments(layoutManager: NSLayoutManager) {
        let commentRegex = /\/\/.*/
        self.highlight(layoutManager: layoutManager,
                       regex: commentRegex,
                       color: NSColor(named: "Comment")!)
    }

    private func highlightMultiLineComments(layoutManager: NSLayoutManager) {
        let commentRegex = /\/\*(?:.|\n)*?\*\//
        self.highlight(layoutManager: layoutManager,
                       regex: commentRegex,
                       color: NSColor(named: "Comment")!)
    }

    private func highlight<T>(layoutManager: NSLayoutManager,
                              regex: Regex<T>,
                              color: NSColor) {
        let textStorage = layoutManager.textStorage!
        let punctuationAttributes: [NSAttributedString.Key: Any] = [.foregroundColor: color]
        let punctuationRanges = textStorage.string.ranges(of: regex)
        for range in punctuationRanges {
            let nsRange = NSRange(range, in: textStorage.string)
            layoutManager.setTemporaryAttributes(punctuationAttributes, forCharacterRange: nsRange)
        }
    }
}
