//
//  AttributedTextView.swift
//  ScintillaApp
//
//  Created by Danielle Kefford on 1/18/25.
//

import AppKit

public class AttributedTextView: NSTextView {
    public var attributedString: NSAttributedString {
        get { textStorage?.copy() as! NSAttributedString }
        set { textStorage?.setAttributedString(newValue) }
    }

    private var _undoManager: UndoManager?

    @objc override public var undoManager: UndoManager? {
        get { _undoManager }
        set { _undoManager = newValue }
    }
}

extension AttributedTextView: AttributedTextViewRepresentable {
    @objc func commentLines(_ sender: Any?) {
        let delegate = self.delegate as! AttributedTextViewDelegate
        var attributedTextEditor = delegate.attributedTextEditor

        // ACHTUNG!!! We need to temporarily disable highlighting
        // to prevent it from firing for every edit, which will
        // cause significant performance issues for larger sets
        // of selections.
        attributedTextEditor.disableHighlighting()

        let oldSelectedRanges = self.selectedRanges

        self.handleCommentSelections(textView: self,
                                     oldSelectedRanges: oldSelectedRanges)

        attributedTextEditor.reenableHighlighting()
        attributedTextEditor.highlighter(self.layoutManager!)
    }

    private func handleCommentSelections(textView: NSTextView,
                                         oldSelectedRanges: [NSValue]) {
        var newSelectedRanges: [NSValue] = []

        textView.undoManager?.disableUndoRegistration()
        for case let rawRange as NSRange in oldSelectedRanges {
            let indices = textView.string.indicesOfLineStarts(range: rawRange)

            var newSelectedRange: NSRange
            if indices.allSatisfy({ index in
                // If we're at the end of the file then return false
                // since there can't possibly be two slash characters there.
                if index == textView.string.endIndex {
                    return false
                }

                let nextIndex = textView.string.index(after: index)
                return textView.string[index...nextIndex] == "//"
            }) {
                // If all of the selected lines begin with '//' then uncomment them all...
                for index in indices {
                    let location = index.utf16Offset(in: textView.string)
                    textView.insertText("", replacementRange: NSRange(location: location, length: 2))
                }

                newSelectedRange = NSRange(
                    location: rawRange.location - 2,
                    length: rawRange.length - 2*(indices.count-1))
            } else {
                // ... otherwise insert comment slashes
                for index in indices {
                    let location = index.utf16Offset(in: textView.string)
                    textView.insertText("//", replacementRange: NSRange(location: location, length: 0))
                }

                newSelectedRange = NSRange(
                    location: rawRange.location + 2,
                    length: rawRange.length + 2*(indices.count-1))
            }

            newSelectedRanges.append(newSelectedRange as NSValue)
        }
        textView.undoManager?.enableUndoRegistration()

        textView.selectedRanges = newSelectedRanges
        textView.undoManager?.registerUndo(
            withTarget: self,
            handler: { delegate in
                delegate.handleCommentSelections(textView: textView,
                                                 oldSelectedRanges: newSelectedRanges)
            })
    }
}
