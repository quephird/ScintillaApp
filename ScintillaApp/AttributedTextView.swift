//
//  AttributedTextView.swift
//  ScintillaApp
//
//  Created by Danielle Kefford on 1/18/25.
//

import AppKit

public class AttributedTextView: NSTextView {}

extension AttributedTextView: AttributedTextViewRepresentable {
    public var attributedString: NSAttributedString {
        get { textStorage?.copy() as! NSAttributedString }
        set { textStorage?.setAttributedString(newValue) }
    }
}
