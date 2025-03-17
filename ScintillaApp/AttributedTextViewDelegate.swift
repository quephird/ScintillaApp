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
        if self.attributedTextEditor.attributedString.string != oldTextView.attributedString.string {
            self.attributedTextEditor.attributedString = oldTextView.attributedString
        }
        self.attributedTextEditor.highlighter(oldTextView.layoutManager!)
    }

    func textViewDidChangeSelection(_ notification: Notification) {
        let textView = notification.object as! AttributedTextView
        let oldSelection = (notification.userInfo!["NSOldSelectedCharacterRange"] as! NSValue).rangeValue
        let newSelection = textView.selectedRange

        self.maybeTrimTrailingWhitespaceFromPreviousLine(textView: textView,
                                                         oldSelection: oldSelection,
                                                         newSelection: newSelection)
    }

    private func maybeTrimTrailingWhitespaceFromPreviousLine(textView: AttributedTextView,
                                                             oldSelection: NSRange,
                                                             newSelection: NSRange) {
        guard !textView.textStorage!.editedMask.contains(.editedCharacters) else {
            return
        }

        guard oldSelection != newSelection else {
            return
        }

        guard oldSelection.intersection(newSelection) == nil else {
            return
        }

        guard textView.attributedString.didLineChange(oldSelection: oldSelection,
                                                      newSelection: newSelection) else {
            return
        }

        let lineRange = textView.attributedString.rangeOfLine(location: oldSelection.location)
        let lineString = textView.attributedString.string[lineRange]
        let predicate: (Character) -> Bool = { char in char.isWhitespace && !char.isNewline }
        let replacementString = String(lineString.trimmingSuffix(while: predicate))

        guard replacementString != lineString else {
            return
        }

        let lineNSRange = NSRange(lineRange, in: textView.attributedString.string)

        // This is to make sure that if any whitespace is trimmed,
        // that it is considered undoable/redoable.
        if textView.shouldChangeText(in: lineNSRange, replacementString: replacementString) {
            textView.textStorage!.replaceCharacters(in: lineNSRange, with: replacementString)
            textView.didChangeText()
        }
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


    func textView(_ textView: NSTextView, doCommandBy commandSelector: Selector) -> Bool {
        switch commandSelector {
        case #selector(AttributedTextView.commentLine(_:)):
            // ACHTUNG!!! We need to temporarily disable highlighting
            // to prevent it from firing for every edit, which will
            // cause significant performance issues for larger sets
            // of selections.
            attributedTextEditor.disableHighlighting()

            let oldSelectedRanges = textView.selectedRanges

            self.handleCommentSelections(textView: textView,
                                         oldSelectedRanges: oldSelectedRanges)

            attributedTextEditor.reenableHighlighting()
            attributedTextEditor.highlighter(textView.layoutManager!)
            return true
        default:
            return false
        }
    }
}
