//
//  StringTests.swift
//  ScintillaApp
//
//  Created by Danielle Kefford on 3/6/25.
//

import Testing
import Foundation
@testable import ScintillaApp

let fileWithOnlyNewlines = """





"""

let nonEmptyFile = """
one
two
three

"""

func makeIndex(string: String, offset: Int) -> String.Index {
    string.index(string.startIndex, offsetBy: offset)
}

struct StringTests {
    @Test func getIndicesForEmptyFile() async throws {
        let emptyFile = ""
        let currentSelection = NSRange(location: 0, length: 0)
        let actual = emptyFile.indicesOfLineStarts(range: currentSelection)
        let expected = [makeIndex(string: nonEmptyFile, offset: 0)]
        #expect(actual == expected)
    }


    @Test func getIndicesForFileWithOnlyNewlinesWithCursorAtBeginningOfFile() async throws {
        let currentSelection = NSRange(location: 0, length: 0)
        let actual = fileWithOnlyNewlines.indicesOfLineStarts(range: currentSelection)
        let expected = [
            makeIndex(string: fileWithOnlyNewlines, offset: 0),
        ]
        #expect(actual == expected)
    }

    @Test func getIndicesForFileWithOnlyNewlinesWithCursorInMiddleOfFile() async throws {
        let currentSelection = NSRange(location: 2, length: 0)
        let actual = fileWithOnlyNewlines.indicesOfLineStarts(range: currentSelection)
        let expected = [
            makeIndex(string: fileWithOnlyNewlines, offset: 2),
        ]
        #expect(actual == expected)
    }

    @Test func getIndicesForFileWithOnlyNewlinesWithCursorAtEndOfFile() async throws {
        let currentSelection = NSRange(location: 4, length: 0)
        let actual = fileWithOnlyNewlines.indicesOfLineStarts(range: currentSelection)
        let expected = [
            makeIndex(string: fileWithOnlyNewlines, offset: 4),
        ]
        #expect(actual == expected)
    }

    @Test func getIndicesForFileWithOnlyNewlinesAndSelectingMultipleLines() async throws {
        let currentSelection = NSRange(location: 1, length: 2)
        let actual = fileWithOnlyNewlines.indicesOfLineStarts(range: currentSelection)
        let expected = [
            makeIndex(string: fileWithOnlyNewlines, offset: 2),
            makeIndex(string: fileWithOnlyNewlines, offset: 1),
        ]
        #expect(actual == expected)
    }


    @Test func getIndicesForNonemptyFileWithCursorAtBeginningOfFile() async throws {
        let currentSelection = NSRange(location: 0, length: 0)
        let actual = nonEmptyFile.indicesOfLineStarts(range: currentSelection)
        let expected = [makeIndex(string: nonEmptyFile, offset: 0)]
        #expect(actual == expected)
    }

    @Test func getIndicesForNonemptyFileWithCursorAtBeginningOfLineInMiddleOfFile() async throws {
        let currentSelection = NSRange(location: 4, length: 0)
        let actual = nonEmptyFile.indicesOfLineStarts(range: currentSelection)
        let expected = [makeIndex(string: nonEmptyFile, offset: 4)]
        #expect(actual == expected)
    }

    @Test func getIndicesForNonemptyFileWithCursorAtMiddleOfLineInMiddleOfFile() async throws {
        let currentSelection = NSRange(location: 6, length: 0)
        let actual = nonEmptyFile.indicesOfLineStarts(range: currentSelection)
        let expected = [makeIndex(string: nonEmptyFile, offset: 4)]
        #expect(actual == expected)
    }

    @Test func getIndicesForNonemptyFileWithCursorAtEndOfLineInMiddleOfFile() async throws {
        let currentSelection = NSRange(location: 7, length: 0)
        let actual = nonEmptyFile.indicesOfLineStarts(range: currentSelection)
        let expected = [makeIndex(string: nonEmptyFile, offset: 4)]
        #expect(actual == expected)
    }

    @Test func getIndicesForNonemptyFileWithCursorAtEndOfFile() async throws {
        let currentSelection = NSRange(location: 14, length: 0)
        let actual = nonEmptyFile.indicesOfLineStarts(range: currentSelection)
        let expected = [
            makeIndex(string: nonEmptyFile, offset: 14),
        ]
        #expect(actual == expected)
    }

    @Test func getIndicesForNonemptyFileWhenFirstTwoCompleteLinesSelected() async throws {
        let currentSelection = NSRange(location: 0, length: 7)
        let actual = nonEmptyFile.indicesOfLineStarts(range: currentSelection)
        let expected = [
            makeIndex(string: nonEmptyFile, offset: 4),
            makeIndex(string: nonEmptyFile, offset: 0),
        ]
        #expect(actual == expected)
    }

    @Test func getIndicesForNonemptyFileWithTwoLinesPartiallySelected() async throws {
        let currentSelection = NSRange(location: 2, length: 4)
        let actual = nonEmptyFile.indicesOfLineStarts(range: currentSelection)
        let expected = [
            makeIndex(string: nonEmptyFile, offset: 4),
            makeIndex(string: nonEmptyFile, offset: 0),
        ]
        #expect(actual == expected)
    }

    @Test func getIndicesForNonemptyFileWithOnePartialLineAndOneCompleteLineSelected() async throws {
        let currentSelection = NSRange(location: 2, length: 5)
        let actual = nonEmptyFile.indicesOfLineStarts(range: currentSelection)
        let expected = [
            makeIndex(string: nonEmptyFile, offset: 4),
            makeIndex(string: nonEmptyFile, offset: 0),
        ]
        #expect(actual == expected)
    }

    @Test func getIndicesForNonemptyFileWithEverythingSelected() async throws {
        let currentSelection = NSRange(location: 0, length: 13)
        let actual = nonEmptyFile.indicesOfLineStarts(range: currentSelection)
        let expected = [
            makeIndex(string: nonEmptyFile, offset: 8),
            makeIndex(string: nonEmptyFile, offset: 4),
            makeIndex(string: nonEmptyFile, offset: 0),
        ]
        #expect(actual == expected)
    }
}
