//
//  AttributedString+lineFunctions.swift
//  ScintillaApp
//
//  Created by Danielle Kefford on 2/17/25.
//

import AppKit

extension NSAttributedString {
    public func didLineChange(oldSelection: NSRange,
                              newSelection: NSRange) -> Bool {
        let startLocation = min(oldSelection.location, newSelection.location)
        let endLocation = max(oldSelection.location, newSelection.location)

        let rawString = self.string

        let startIndex = String.Index(utf16Offset: startLocation, in: rawString)
        let endIndex = String.Index(utf16Offset: endLocation, in: rawString)

        return rawString[startIndex ..< endIndex].contains("\n")
    }

    public func rangeOfLine(location: Int) -> Range<String.Index> {
        // Get index for location
        let locIndex = String.Index(utf16Offset: location, in: self.string)

        // Scan backwards
        let startIndex: String.Index
        if let index = self.string[..<locIndex].lastIndex(of: "\n") {
            startIndex = index
        } else {
            startIndex = self.string.startIndex
        }

        // Scan forwards
        let endIndex: String.Index
        if let index = self.string[locIndex...].firstIndex(of: "\n") {
            endIndex = index
        } else {
            endIndex = self.string.endIndex
        }

        return startIndex ..< endIndex
    }
}
