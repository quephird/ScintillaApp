//
//  StringTests.swift
//  ScintillaApp
//
//  Created by Danielle Kefford on 3/6/25.
//

import Testing
import Foundation
@testable import ScintillaApp

let nonEmptyFile = """
one
two
three

"""

func makeIndex(string: String, offset: Int) -> String.Index {
    string.index(string.startIndex, offsetBy: offset)
}

struct StringTests {
    @Test func getIndicesForNonemptyFileWhenCursorIsAtTheBeginning() async throws {
        let currentSelection = NSRange(location: 0, length: 0)
        let actual = nonEmptyFile.indicesOfLineStarts(range: currentSelection)
        let expected = [makeIndex(string: nonEmptyFile, offset: 0)]
        #expect(actual == expected)
    }

    @Test func getIndicesForNonemptyFileWhenFirstTwoLiinesSelected() async throws {
        let currentSelection = NSRange(location: 0, length: 8)
        let actual = nonEmptyFile.indicesOfLineStarts(range: currentSelection)
        let expected = [
            makeIndex(string: nonEmptyFile, offset: 4),
            makeIndex(string: nonEmptyFile, offset: 0),
        ]
        #expect(actual == expected)
    }
}
