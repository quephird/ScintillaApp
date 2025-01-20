//
//  AttributedTextViewDelegate.swift
//  ScintillaApp
//
//  Created by Danielle Kefford on 1/18/25.
//

import AppKit
import SwiftUI

class AttributedTextViewDelegate: NSObject, NSTextViewDelegate {
    public private(set) var attributedTextEditor: AttributedTextEditor

    internal init(attributedTextEditor: AttributedTextEditor) {
        self.attributedTextEditor = attributedTextEditor
    }

    func textDidChange(_ notification: Notification) {
        let oldTextView = notification.object as! AttributedTextView
        self.attributedTextEditor.attributedString = oldTextView.attributedString
    }
}
