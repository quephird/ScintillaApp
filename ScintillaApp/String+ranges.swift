//
//  String+ranges.swift
//  ScintillaApp
//
//  Created by Danielle Kefford on 1/20/25.
//

import Foundation

extension String {
    func ranges(of substring: String) -> [Range<String.Index>] {
        var result: [Range<String.Index>] = []
        var startIndex = self.startIndex
        while startIndex < self.endIndex,
              let range = self.range(of: substring, range: startIndex..<self.endIndex) {
            result.append(range)
            startIndex = range.upperBound
        }

        return result
    }
}

extension String {
    func indicesOfLineStarts(range: NSRange) -> [String.Index] {
        // TODO: How to handle empty file
//        if self.count == 0 {
//            return []
//        }
//
//        var startIndex = String.Index(utf16Offset: range.location, in: self)
//
//        if startIndex == self.endIndex {
//            return [startIndex]
//        }

        var startIndex = String.Index(utf16Offset: range.location, in: self)
        if startIndex != self.endIndex && self[startIndex] == "\n" {
            startIndex = self.index(before: startIndex)
        }

        var endIndex = String.Index(utf16Offset: range.location + range.length, in: self)
        if endIndex == self.endIndex || self[endIndex] == "\n" || range.length > 0 {
            endIndex = self.index(before: endIndex)
        }

        // Move backwards through string until we hit the stop index
        var newlineIndices: [String.Index] = []
        var currentIndex = endIndex
        repeat {
            if let index = self[..<currentIndex].lastIndex(of: "\n") {
                currentIndex = index
                newlineIndices.append(self.index(after: index))
            } else {
                // If we got here, then we're on the first line of the string
                newlineIndices.append(self.startIndex)
                break
            }
        } while currentIndex > startIndex

        return newlineIndices
    }
}
