//
//  String+ranges.swift
//  ScintillaApp
//
//  Created by Danielle Kefford on 1/20/25.
//

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
