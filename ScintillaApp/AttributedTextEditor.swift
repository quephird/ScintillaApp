//
//  AttributedTextEditor.swift
//  ScintillaApp
//
//  Created by Danielle Kefford on 1/18/25.
//

import AppKit
import SwiftUI

@MainActor
struct AttributedTextEditor: NSViewRepresentable {
    public init(text: Binding<NSAttributedString>) {
        self._attributedString = text
    }

    @Binding public var attributedString: NSAttributedString

    public let scrollView = AttributedTextView.scrollableTextView()
    
    var defaultAttributes: [NSAttributedString.Key : Any] = [
        .foregroundColor: #colorLiteral(red: 0.5568627715, green: 0.3529411852, blue: 0.9686274529, alpha: 1),
        .font: NSFont(descriptor: .preferredFontDescriptor(forTextStyle: .body).withSymbolicTraits(.monoSpace), size: 14)!
    ]
    
    var attributedStringWithDefaults: NSAttributedString {
        let withDefaults = attributedString.mutableCopy() as! NSMutableAttributedString
        withDefaults.addAttributes(defaultAttributes, range: NSRange(location: 0, length: withDefaults.length))
        return withDefaults
    }

    public var textView: AttributedTextView {
        scrollView.documentView as? AttributedTextView ?? AttributedTextView()
    }

    public func makeNSView(context: Context) -> some NSView {
        textView.attributedString = attributedStringWithDefaults
        textView.textColor = .purple
        textView.backgroundColor = NSColor(red: 0.1, green: 0.1, blue: 0.1, alpha: 1.0)
        textView.drawsBackground = true
        scrollView.backgroundColor = NSColor(red: 0.1, green: 0.1, blue: 0.1, alpha: 1.0)
        scrollView.drawsBackground = true
        return scrollView
    }

    public func updateNSView(_ view: NSViewType, context: Context) {
        textView.attributedString = attributedStringWithDefaults
    }
}
