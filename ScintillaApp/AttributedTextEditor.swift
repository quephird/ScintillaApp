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
        let withDefaults = attributedString.mutableCopy() as! NSMutableAttributedString
        withDefaults.addAttributes(defaultAttributes, range: NSRange(location: 0, length: withDefaults.length))
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
        view.attributedString = attributedStringWithDefaults
    }
}
