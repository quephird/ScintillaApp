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
    public var highlighter: (NSLayoutManager) -> Void
    private var previousHighlighter: (NSLayoutManager) -> Void = { _ in }

    @SwiftUI.Environment(\.undoManager) var undoManager

    mutating public func disableHighlighting() {
        self.previousHighlighter = self.highlighter
        self.highlighter = { _ in }
    }

    mutating public func reenableHighlighting() {
        self.highlighter = self.previousHighlighter
        self.previousHighlighter = { _ in }
    }

    private static var defaultFont: NSFont = NSFont(
        descriptor: .preferredFontDescriptor(
            forTextStyle: .body
        ).withSymbolicTraits(
            .monoSpace
        ),
        size: 14
    )!

    public init(text: Binding<NSAttributedString>,
                highlighter: @escaping (NSLayoutManager) -> Void) {
        self._attributedString = text
        self.highlighter = highlighter
    }

    var defaultAttributes: [NSAttributedString.Key : Any] = [
        .foregroundColor: NSColor(named: "DefaultText")!,
        .font: Self.defaultFont
    ]

    var attributedStringWithDefaults: NSAttributedString {
        let withDefaults = attributedString.mutableCopy() as! NSMutableAttributedString
        withDefaults
            .addAttributes(
                defaultAttributes,
                range: NSRange(
                    location: 0,
                    length: withDefaults.length
                )
            )
        return withDefaults
    }

    public func makeCoordinator() -> AttributedTextViewDelegate {
        return AttributedTextViewDelegate(attributedTextEditor: self)
    }

    private func updateText(attributedTextView: AttributedTextView) {
        if self.attributedStringWithDefaults.string != attributedTextView.attributedString.string {
            let currentCursorRange = attributedTextView.selectedRanges
            defer {
                attributedTextView.selectedRanges = currentCursorRange
            }

            attributedTextView.attributedString = self.attributedStringWithDefaults
            self.highlighter(attributedTextView.layoutManager!)
        }
    }

    public func makeNSView(context: Context) -> NSView {
        let scrollView = AttributedTextView.scrollableTextView()
        let attributedTextView = scrollView.documentView as! AttributedTextView
        self.updateText(attributedTextView: attributedTextView)

        let lineNumberView = LineNumberView(textView: attributedTextView)
        scrollView.verticalRulerView = lineNumberView
        scrollView.hasVerticalRuler = true
        scrollView.rulersVisible = true

        attributedTextView.isAutomaticTextReplacementEnabled = false
        attributedTextView.delegate = context.coordinator
        attributedTextView.backgroundColor = NSColor(named: "EditorBackground")!
        attributedTextView.typingAttributes = defaultAttributes
        attributedTextView.drawsBackground = true
        attributedTextView.undoManager = self.undoManager

        scrollView.backgroundColor = NSColor(named: "EditorBackground")!
        scrollView.drawsBackground = true
        scrollView.scrollerKnobStyle = .light
        return scrollView
    }

    public func updateNSView(_ view: NSView, context: Context) {
        let attributedTextView = (view as! NSScrollView).documentView as! AttributedTextView
        self.updateText(attributedTextView: attributedTextView)
    }
}
