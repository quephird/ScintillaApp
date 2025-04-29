//
//  TokenizerTests.swift
//  ScintillaApp
//
//  Created by Danielle Kefford on 2/17/25.
//

import Testing
@testable import ScintillaApp

struct TokenizerTests {
    @Test func scanningOfOneCharacterLexemes() throws {
        let source = "( ) { } [ ] , . : = + - * / ^"
        var tokenizer = Tokenizer(source: source)

        let actual = try! tokenizer.scanTokens()
        let expected: [Token] = [
            Token(type: .leftParen, lexeme: makeLexeme(source: source, offset: 0, length: 1)),
            Token(type: .rightParen, lexeme: makeLexeme(source: source, offset: 2, length: 1)),
            Token(type: .leftBrace, lexeme: makeLexeme(source: source, offset: 4, length: 1)),
            Token(type: .rightBrace, lexeme: makeLexeme(source: source, offset: 6, length: 1)),
            Token(type: .leftBracket, lexeme: makeLexeme(source: source, offset: 8, length: 1)),
            Token(type: .rightBracket, lexeme: makeLexeme(source: source, offset: 10, length: 1)),
            Token(type: .comma, lexeme: makeLexeme(source: source, offset: 12, length: 1)),
            Token(type: .dot, lexeme: makeLexeme(source: source, offset: 14, length: 1)),
            Token(type: .colon, lexeme: makeLexeme(source: source, offset: 16, length: 1)),
            Token(type: .equal, lexeme: makeLexeme(source: source, offset: 18, length: 1)),
            Token(type: .plus, lexeme: makeLexeme(source: source, offset: 20, length: 1)),
            Token(type: .minus, lexeme: makeLexeme(source: source, offset: 22, length: 1)),
            Token(type: .star, lexeme: makeLexeme(source: source, offset: 24, length: 1)),
            Token(type: .slash, lexeme: makeLexeme(source: source, offset: 26, length: 1)),
            Token(type: .caret, lexeme: makeLexeme(source: source, offset: 28, length: 1)),
            Token(type: .eof, lexeme: makeLexeme(source: source, offset: 29, length: 0)),
        ]

        #expect(actual == expected)
    }

    @Test func scanningOfNumbers() throws {
        let source = "123 456.789 0.577"
        var tokenizer = Tokenizer(source: source)

        let actual = try! tokenizer.scanTokens()
        let expected: [Token] = [
            Token(type: .double, lexeme: makeLexeme(source: source, offset: 0, length: 3)),
            Token(type: .double, lexeme: makeLexeme(source: source, offset: 4, length: 7)),
            Token(type: .double, lexeme: makeLexeme(source: source, offset: 12, length: 5)),
            Token(type: .eof, lexeme: makeLexeme(source: source, offset: 13, length: 0)),
        ]

        #expect(actual == expected)
    }

    @Test func scanningOfKeywords() throws {
        let source = "let in func true false as"
        var tokenizer = Tokenizer(source: source)

        let actual = try! tokenizer.scanTokens()
        let expected: [Token] = [
            Token(type: .let, lexeme: makeLexeme(source: source, offset: 0, length: 3)),
            Token(type: .in, lexeme: makeLexeme(source: source, offset: 4, length: 2)),
            Token(type: .func, lexeme: makeLexeme(source: source, offset: 7, length: 4)),
            Token(type: .true, lexeme: makeLexeme(source: source, offset: 12, length: 4)),
            Token(type: .false, lexeme: makeLexeme(source: source, offset: 17, length: 5)),
            Token(type: .as, lexeme: makeLexeme(source: source, offset: 23, length: 2)),
            Token(type: .eof, lexeme: makeLexeme(source: source, offset: 24, length: 0)),
        ]

        #expect(actual == expected)
    }

    @Test func scanningOfIdentifiers() throws {
        let source = "foo bar baz"
        var tokenizer = Tokenizer(source: source)

        let actual = try! tokenizer.scanTokens()
        let expected: [Token] = [
            Token(type: .identifier, lexeme: makeLexeme(source: source, offset: 0, length: 3)),
            Token(type: .identifier, lexeme: makeLexeme(source: source, offset: 4, length: 3)),
            Token(type: .identifier, lexeme: makeLexeme(source: source, offset: 8, length: 3)),
            Token(type: .eof, lexeme: makeLexeme(source: source, offset: 11, length: 0)),
        ]

        #expect(actual == expected)
    }

    @Test func scanningOfDoubleSlashComment() throws {
        let source = "let theAnswer = 42 // What is the question?"
        var tokenizer = Tokenizer(source: source)

        let actual = try! tokenizer.scanTokens()
        let expected: [Token] = [
            Token(type: .let, lexeme: makeLexeme(source: source, offset: 0, length: 3)),
            Token(type: .identifier, lexeme: makeLexeme(source: source, offset: 4, length: 9)),
            Token(type: .equal, lexeme: makeLexeme(source: source, offset: 14, length: 1)),
            Token(type: .double, lexeme: makeLexeme(source: source, offset: 16, length: 2)),
            Token(type: .eof, lexeme: makeLexeme(source: source, offset: 43, length: 0)),
        ]

        #expect(actual == expected)
    }

    @Test func scanningOfSlashStarComment() throws {
        let source = "let theAnswer = 42 /* What is the question? */"
        var tokenizer = Tokenizer(source: source)

        let actual = try! tokenizer.scanTokens()
        let expected: [Token] = [
            Token(type: .let, lexeme: makeLexeme(source: source, offset: 0, length: 3)),
            Token(type: .identifier, lexeme: makeLexeme(source: source, offset: 4, length: 9)),
            Token(type: .equal, lexeme: makeLexeme(source: source, offset: 14, length: 1)),
            Token(type: .double, lexeme: makeLexeme(source: source, offset: 16, length: 2)),
            Token(type: .eof, lexeme: makeLexeme(source: source, offset: 46, length: 0)),
        ]

        #expect(actual == expected)
    }

    @Test func scanningOfIncompleteSlashStarComment() throws {
        let source = "let theAnswer = 42 /* What is the question?"
        var tokenizer = Tokenizer(source: source)

        let badToken = Token(type: .unknown, lexeme: "/* What is the question?")
        #expect(throws: TokenizerError.unterminatedComment(badToken)) {
            try tokenizer.scanTokens()
        }
    }

    @Test func scanningOfLetDeclaration() throws {
        let source = """
let shape = Sphere()
    .translate(x: 1.0, y: 2.0, z: 3.0)
"""
        var tokenizer = Tokenizer(source: source)

        let actual = try! tokenizer.scanTokens()
        let expected: [Token] = [
            Token(type: .let, lexeme: makeLexeme(source: source, offset: 0, length: 3)),
            Token(type: .identifier, lexeme: makeLexeme(source: source, offset: 4, length: 5)),
            Token(type: .equal, lexeme: makeLexeme(source: source, offset: 10, length: 1)),
            Token(type: .identifier, lexeme: makeLexeme(source: source, offset: 12, length: 6)),
            Token(type: .leftParen, lexeme: makeLexeme(source: source, offset: 18, length: 1)),
            Token(type: .rightParen, lexeme: makeLexeme(source: source, offset: 19, length: 1)),
            Token(type: .dot, lexeme: makeLexeme(source: source, offset: 25, length: 1)),
            Token(type: .identifier, lexeme: makeLexeme(source: source, offset: 26, length: 9)),
            Token(type: .leftParen, lexeme: makeLexeme(source: source, offset: 35, length: 1)),
            Token(type: .identifier, lexeme: makeLexeme(source: source, offset: 36, length: 1)),
            Token(type: .colon, lexeme: makeLexeme(source: source, offset: 37, length: 1)),
            Token(type: .double, lexeme: makeLexeme(source: source, offset: 39, length: 3)),
            Token(type: .comma, lexeme: makeLexeme(source: source, offset: 42, length: 1)),
            Token(type: .identifier, lexeme: makeLexeme(source: source, offset: 44, length: 1)),
            Token(type: .colon, lexeme: makeLexeme(source: source, offset: 45, length: 1)),
            Token(type: .double, lexeme: makeLexeme(source: source, offset: 47, length: 3)),
            Token(type: .comma, lexeme: makeLexeme(source: source, offset: 50, length: 1)),
            Token(type: .identifier, lexeme: makeLexeme(source: source, offset: 52, length: 1)),
            Token(type: .colon, lexeme: makeLexeme(source: source, offset: 53, length: 1)),
            Token(type: .double, lexeme: makeLexeme(source: source, offset: 55, length: 3)),
            Token(type: .rightParen, lexeme: makeLexeme(source: source, offset: 58, length: 1)),
            Token(type: .eof, lexeme: makeLexeme(source: source, offset: 59, length: 0)),
        ]

        #expect(actual == expected)
    }
}
