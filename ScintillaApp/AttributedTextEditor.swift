//
//  AttributedTextEditor.swift
//  ScintillaApp
//
//  Created by Danielle Kefford on 1/18/25.
//

import AppKit
import SwiftUI

struct AttributedTextEditor: NSViewRepresentable {
    @Binding public var attributedString: NSAttributedString

    public init(text: Binding<NSAttributedString>) {
        self._attributedString = text
    }
    
    var defaultAttributes: [NSAttributedString.Key : Any] = [
        .foregroundColor: #colorLiteral(red: 0.5568627715, green: 0.3529411852, blue: 0.9686274529, alpha: 1),
        .font: NSFont(descriptor: .preferredFontDescriptor(forTextStyle: .body).withSymbolicTraits(.monoSpace), size: 14)!
    ]

    var attributedStringWithDefaults: NSAttributedString {
        var withDefaults = attributedString.mutableCopy() as! NSMutableAttributedString
        withDefaults.addAttributes(defaultAttributes, range: NSRange(location: 0, length: withDefaults.length))
        self.addSyntaxHighlighting(attributedString: &withDefaults)
        return withDefaults
    }

    public func makeCoordinator() -> AttributedTextViewDelegate {
        return AttributedTextViewDelegate(attributedTextEditor: self)
    }

    public func makeNSView(context: Context) -> NSView {
        let scrollView = AttributedTextView.scrollableTextView()
        let textView = scrollView.documentView as! AttributedTextView
        textView.delegate = context.coordinator
        textView.textColor = .purple
        textView.backgroundColor = NSColor(red: 0.1, green: 0.1, blue: 0.1, alpha: 1.0)
        textView.drawsBackground = true
        scrollView.backgroundColor = NSColor(red: 0.1, green: 0.1, blue: 0.1, alpha: 1.0)
        scrollView.drawsBackground = true
        scrollView.scrollerKnobStyle = .light
        return scrollView
    }

    public func updateNSView(_ view: NSView, context: Context) {
        let view = (view as! NSScrollView).documentView as! AttributedTextView
        let currentCursorRange = view.selectedRanges
        view.attributedString = attributedStringWithDefaults
        view.selectedRanges = currentCursorRange
    }

    private func addSyntaxHighlighting(attributedString: inout NSMutableAttributedString) {
        let code = attributedString.string

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
                    attributedString.addAttributes(attributes, range: nsRange)
                }
            }
        }
    
        let paramAttributes: [NSAttributedString.Key: Any] = [.foregroundColor: #colorLiteral(red: 0, green: 0.4649228454, blue: 0.5589954257, alpha: 1)]
        let paramNameRegex = /\p{ID_Start}\p{ID_Continue}*(?=\s*:)/
        let paramRanges = code.ranges(of: paramNameRegex)
        for range in paramRanges {
            let nsRange = NSRange(range, in: code)
            attributedString.addAttributes(paramAttributes, range: nsRange)
        }

        let numberAttributes: [NSAttributedString.Key: Any] = [.foregroundColor: #colorLiteral(red: 1, green: 0.9946382642, blue: 0.3478766382, alpha: 1)]
        let numberRegex = /-?(\d+.)?\d+/
        let numberRanges = code.ranges(of: numberRegex)
        for range in numberRanges {
            let nsRange = NSRange(range, in: code)
            attributedString.addAttributes(numberAttributes, range: nsRange)
        }

        let methodAttributes: [NSAttributedString.Key: Any] = [.foregroundColor: #colorLiteral(red: 0.1923640966, green: 0.5559594035, blue: 0.3243826628, alpha: 1)]
        let methodRegex = /\.(?<method>\p{ID_Start}\p{ID_Continue}*)/
        let methodMatches = code.matches(of: methodRegex)
        for match in methodMatches {
            let swiftRange = match.method.startIndex ..< match.method.endIndex
            let nsRange = NSRange(swiftRange, in: code)
            attributedString.addAttributes(methodAttributes, range: nsRange)
        }

        let punctuationAttributes: [NSAttributedString.Key: Any] = [.foregroundColor: #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)]
        let punctuationRegex = /\.|:|\(|\)|\{|\}|,/
        let punctuationRanges = code.ranges(of: punctuationRegex)
        for range in punctuationRanges {
            let nsRange = NSRange(range, in: code)
            attributedString.addAttributes(punctuationAttributes, range: nsRange)
        }
    }
}
