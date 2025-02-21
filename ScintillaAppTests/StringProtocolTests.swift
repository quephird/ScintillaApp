//
//  StringProtocolTests.swift
//  ScintillaApp
//
//  Created by Danielle Kefford on 2/20/25.
//

import Testing
@testable import ScintillaApp

struct StringProtocolTests {
    @Test func trimmingStringWithSuffix() async throws {
        let string = "This is a test.    "
        let trimmedSubstring = string.trimmingSuffix(while: \.isWhitespace)
        #expect(trimmedSubstring == "This is a test.")
    }

    @Test func trimmingstrigWithoutSuffix() async throws {
        let string = "This is a test."
        let trimmedSubstring = string.trimmingSuffix(while: \.isWhitespace)
        #expect(trimmedSubstring == "This is a test.")
    }
}
