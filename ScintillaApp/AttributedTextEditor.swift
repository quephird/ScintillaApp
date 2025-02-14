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
    private var highlighter: (NSTextStorage) -> Void

    private static var defaultFont: NSFont = NSFont(
        descriptor: .preferredFontDescriptor(
            forTextStyle: .body
        ).withSymbolicTraits(
            .monoSpace
        ),
        size: 14
    )!

    public init(text: Binding<NSAttributedString>,
                highlighter: @escaping (NSTextStorage) -> Void) {
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

    public func makeNSView(context: Context) -> NSView {
        let scrollView = AttributedTextView.scrollableTextView()
        let textView = scrollView.documentView as! AttributedTextView
        textView.delegate = context.coordinator
        textView.backgroundColor = NSColor(named: "EditorBackground")!
        textView.drawsBackground = true

        scrollView.backgroundColor = NSColor(named: "EditorBackground")!
        scrollView.drawsBackground = true
        scrollView.scrollerKnobStyle = .light
        return scrollView
    }

    public func updateNSView(_ view: NSView, context: Context) {
        let view = (view as! NSScrollView).documentView as! AttributedTextView
        let currentCursorRange = view.selectedRanges
        view.attributedString = attributedStringWithDefaults
        self.highlighter(view.textStorage!)
        view.selectedRanges = currentCursorRange
    }
}
