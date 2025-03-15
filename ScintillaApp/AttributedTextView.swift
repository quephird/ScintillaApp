//
//  AttributedTextView.swift
//  ScintillaApp
//
//  Created by Danielle Kefford on 1/18/25.
//

import AppKit

public class AttributedTextView: NSTextView {
    @IBAction func commentLine(_ sender: Any?) {
        self.doCommand(by: #selector(self.commentLine(_:)))
    }
}

extension AttributedTextView: AttributedTextViewRepresentable {
    public var attributedString: NSAttributedString {
        get { textStorage?.copy() as! NSAttributedString }
        set { textStorage?.setAttributedString(newValue) }
    }
}
