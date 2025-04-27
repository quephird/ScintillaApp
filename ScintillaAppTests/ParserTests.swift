//
//  ParserTests.swift
//  ScintillaApp
//
//  Created by Danielle Kefford on 2/18/25.
//

import Testing
@testable import ScintillaApp

struct ParserTests {
    @Test func parseNumericLiteralExpression() throws {
        let source = "42"
        let tokens: [Token] = [
            Token(type: .double, lexeme: makeLexeme(source: source, offset: 0, length: 2)),
            Token(type: .eof, lexeme: makeLexeme(source: source, offset: 2, length: 0)),
        ]
        var parser = Parser(tokens: tokens)

        let actual = try parser.parseExpression()
        let expected: Expression<UnresolvedLocation> =
            .doubleLiteral(
                Token(type: .double, lexeme: makeLexeme(source: source, offset: 0, length: 2)),
                42)
        #expect(actual == expected)
    }

    @Test func parseBooleanLiteralExpression() throws {
        let source = "true"
        let tokens: [Token] = [
            Token(type: .true, lexeme: makeLexeme(source: source, offset: 0, length: 4)),
            Token(type: .eof, lexeme: makeLexeme(source: source, offset: 4, length: 0)),
        ]
        var parser = Parser(tokens: tokens)

        let actual = try parser.parseExpression()
        let expected: Expression<UnresolvedLocation> =
            .boolLiteral(
                Token(type: .true, lexeme: makeLexeme(source: source, offset: 0, length: 4)),
                true)
        #expect(actual == expected)
    }

    @Test func parsegroupedExpression() throws {
        let source = "(((42)))"
        let tokens: [Token] = [
            Token(type: .leftParen, lexeme: makeLexeme(source: source, offset: 0, length: 1)),
            Token(type: .leftParen, lexeme: makeLexeme(source: source, offset: 1, length: 1)),
            Token(type: .leftParen, lexeme: makeLexeme(source: source, offset: 2, length: 1)),
            Token(type: .double, lexeme: makeLexeme(source: source, offset: 3, length: 2)),
            Token(type: .rightParen, lexeme: makeLexeme(source: source, offset: 5, length: 1)),
            Token(type: .rightParen, lexeme: makeLexeme(source: source, offset: 6, length: 1)),
            Token(type: .rightParen, lexeme: makeLexeme(source: source, offset: 7, length: 1)),
            Token(type: .eof, lexeme: makeLexeme(source: source, offset: 8, length: 0)),
        ]
        var parser = Parser(tokens: tokens)

        let actual = try parser.parseExpression()
        let expected: Expression<UnresolvedLocation> =
            .doubleLiteral(
                Token(type: .double, lexeme: makeLexeme(source: source, offset: 3, length: 2)),
                42)
        #expect(actual == expected)
    }

    @Test func parseInvalidGroupedExpression() throws {
        let source = "(((42))"
        let tokens: [Token] = [
            Token(type: .leftParen, lexeme: makeLexeme(source: source, offset: 0, length: 1)),
            Token(type: .leftParen, lexeme: makeLexeme(source: source, offset: 1, length: 1)),
            Token(type: .leftParen, lexeme: makeLexeme(source: source, offset: 2, length: 1)),
            Token(type: .double, lexeme: makeLexeme(source: source, offset: 3, length: 2)),
            Token(type: .rightParen, lexeme: makeLexeme(source: source, offset: 5, length: 1)),
            Token(type: .rightParen, lexeme: makeLexeme(source: source, offset: 6, length: 1)),
            Token(type: .eof, lexeme: makeLexeme(source: source, offset: 7, length: 0)),
        ]
        var parser = Parser(tokens: tokens)

        #expect(throws: ParseError.self) {
            try parser.parseExpression()
        }
    }

    @Test func parseUnaryExpression() throws {
        let source = "-42"
        let tokens: [Token] = [
            Token(type: .minus, lexeme: makeLexeme(source: source, offset: 0, length: 1)),
            Token(type: .double, lexeme: makeLexeme(source: source, offset: 1, length: 2)),
            Token(type: .eof, lexeme: makeLexeme(source: source, offset: 3, length: 0)),
        ]
        var parser = Parser(tokens: tokens)

        let actual = try parser.parseExpression()
        let expected: Expression<UnresolvedLocation> =
            .unary(
                Token(type: .minus, lexeme: makeLexeme(source: source, offset: 0, length: 1)),
                .doubleLiteral(
                    Token(type: .double, lexeme: makeLexeme(source: source, offset: 1, length: 2)),
                    42))
        #expect(actual == expected)
    }

    @Test func parseFactorExpression() throws {
        let source = "21 * 2"
        let tokens: [Token] = [
            Token(type: .double, lexeme: makeLexeme(source: source, offset: 0, length: 2)),
            Token(type: .star, lexeme: makeLexeme(source: source, offset: 3, length: 1)),
            Token(type: .double, lexeme: makeLexeme(source: source, offset: 5, length: 1)),
            Token(type: .eof, lexeme: makeLexeme(source: source, offset: 6, length: 0)),
        ]
        var parser = Parser(tokens: tokens)

        let actual = try parser.parseExpression()
        let expected: Expression<UnresolvedLocation> =
            .binary(
                .doubleLiteral(
                    Token(type: .double, lexeme: makeLexeme(source: source, offset: 0, length: 2)),
                    21),
                Token(type: .star, lexeme: makeLexeme(source: source, offset: 3, length: 1)),
                .doubleLiteral(
                    Token(type: .double, lexeme: makeLexeme(source: source, offset: 5, length: 1)),
                    2))
        #expect(actual == expected)
    }

    @Test func parseTermExpression() throws {
        let source = "23 + 19"
        let tokens: [Token] = [
            Token(type: .double, lexeme: makeLexeme(source: source, offset: 0, length: 2)),
            Token(type: .plus, lexeme: makeLexeme(source: source, offset: 3, length: 1)),
            Token(type: .double, lexeme: makeLexeme(source: source, offset: 5, length: 2)),
            Token(type: .eof, lexeme: makeLexeme(source: source, offset: 7, length: 0)),
        ]
        var parser = Parser(tokens: tokens)

        let actual = try parser.parseExpression()
        let expected: Expression<UnresolvedLocation> =
            .binary(
                .doubleLiteral(
                    Token(type: .double, lexeme: makeLexeme(source: source, offset: 0, length: 2)),
                    23),
                Token(type: .plus, lexeme: makeLexeme(source: source, offset: 3, length: 1)),
                .doubleLiteral(
                    Token(type: .double, lexeme: makeLexeme(source: source, offset: 5, length: 2)),
                    19))
        #expect(actual == expected)
    }

    @Test func parseExponentialExpression() throws {
        let source = "6.48 ^ 2"
        let tokens: [Token] = [
            Token(type: .double, lexeme: makeLexeme(source: source, offset: 0, length: 4)),
            Token(type: .caret, lexeme: makeLexeme(source: source, offset: 5, length: 1)),
            Token(type: .double, lexeme: makeLexeme(source: source, offset: 7, length: 1)),
            Token(type: .eof, lexeme: makeLexeme(source: source, offset: 8, length: 0)),
        ]
        var parser = Parser(tokens: tokens)

        let actual = try parser.parseExpression()
        let expected: Expression<UnresolvedLocation> =
            .binary(
                .doubleLiteral(
                    Token(type: .double, lexeme: makeLexeme(source: source, offset: 0, length: 4)),
                    6.48),
                Token(type: .caret, lexeme: makeLexeme(source: source, offset: 5, length: 1)),
                .doubleLiteral(
                    Token(type: .double, lexeme: makeLexeme(source: source, offset: 7, length: 1)),
                    2))
        #expect(actual == expected)
    }

    @Test func parseTuple2Expression() throws {
        let source = "(1, 2)"
        let tokens: [Token] = [
            Token(type: .leftParen, lexeme: makeLexeme(source: source, offset: 0, length: 1)),
            Token(type: .double, lexeme: makeLexeme(source: source, offset: 1, length: 1)),
            Token(type: .comma, lexeme: makeLexeme(source: source, offset: 2, length: 1)),
            Token(type: .double, lexeme: makeLexeme(source: source, offset: 4, length: 1)),
            Token(type: .rightParen, lexeme: makeLexeme(source: source, offset: 5, length: 1)),
            Token(type: .eof, lexeme: makeLexeme(source: source, offset: 6, length: 0)),
        ]
        var parser = Parser(tokens: tokens)

        let actual = try parser.parseExpression()
        let expected: Expression<UnresolvedLocation> =
            .tuple2(
                Token(type: .leftParen, lexeme: makeLexeme(source: source, offset: 0, length: 1)),
                .doubleLiteral(
                    Token(type: .double, lexeme: makeLexeme(source: source, offset: 1, length: 1)),
                    1),
                .doubleLiteral(
                    Token(type: .double, lexeme: makeLexeme(source: source, offset: 4, length: 1)),
                    2))
        #expect(actual == expected)
    }

    @Test func parseTuple3Expression() throws {
        let source = "(1, 2, 3)"
        let tokens: [Token] = [
            Token(type: .leftParen, lexeme: makeLexeme(source: source, offset: 0, length: 1)),
            Token(type: .double, lexeme: makeLexeme(source: source, offset: 1, length: 1)),
            Token(type: .comma, lexeme: makeLexeme(source: source, offset: 2, length: 1)),
            Token(type: .double, lexeme: makeLexeme(source: source, offset: 4, length: 1)),
            Token(type: .comma, lexeme: makeLexeme(source: source, offset: 5, length: 1)),
            Token(type: .double, lexeme: makeLexeme(source: source, offset: 7, length: 1)),
            Token(type: .rightParen, lexeme: makeLexeme(source: source, offset: 8, length: 1)),
            Token(type: .eof, lexeme: makeLexeme(source: source, offset: 9, length: 0)),
        ]
        var parser = Parser(tokens: tokens)

        let actual = try parser.parseExpression()
        let expected: Expression<UnresolvedLocation> =
            .tuple3(
                Token(type: .leftParen, lexeme: makeLexeme(source: source, offset: 0, length: 1)),
                .doubleLiteral(
                    Token(type: .double, lexeme: makeLexeme(source: source, offset: 1, length: 1)),
                    1),
                .doubleLiteral(
                    Token(type: .double, lexeme: makeLexeme(source: source, offset: 4, length: 1)),
                    2),
                .doubleLiteral(
                    Token(type: .double, lexeme: makeLexeme(source: source, offset: 7, length: 1)),
                    3))
        #expect(actual == expected)
    }

    @Test func parseListExpression() throws {
        let source = "[1, 2, 3]"
        let tokens: [Token] = [
            Token(type: .leftBracket, lexeme: makeLexeme(source: source, offset: 0, length: 1)),
            Token(type: .double, lexeme: makeLexeme(source: source, offset: 1, length: 1)),
            Token(type: .comma, lexeme: makeLexeme(source: source, offset: 2, length: 1)),
            Token(type: .double, lexeme: makeLexeme(source: source, offset: 4, length: 1)),
            Token(type: .comma, lexeme: makeLexeme(source: source, offset: 5, length: 1)),
            Token(type: .double, lexeme: makeLexeme(source: source, offset: 7, length: 1)),
            Token(type: .rightBracket, lexeme: makeLexeme(source: source, offset: 8, length: 1)),
            Token(type: .eof, lexeme: makeLexeme(source: source, offset: 9, length: 0)),
        ]
        var parser = Parser(tokens: tokens)

        let actual = try parser.parseExpression()
        let expected: Expression<UnresolvedLocation> =
            .list(
                Token(type: .leftBracket, lexeme: makeLexeme(source: source, offset: 0, length: 1)),
                [
                    .doubleLiteral(
                        Token(type: .double, lexeme: makeLexeme(source: source, offset: 1, length: 1)),
                        1),
                    .doubleLiteral(
                        Token(type: .double, lexeme: makeLexeme(source: source, offset: 4, length: 1)),
                        2),
                    .doubleLiteral(
                        Token(type: .double, lexeme: makeLexeme(source: source, offset: 7, length: 1)),
                        3)
                ])
        #expect(actual == expected)
    }

    @Test func parseLetDeclaration() throws {
        let source = "let theAnswer = 42"
        let tokens: [Token] = [
            Token(type: .let, lexeme: makeLexeme(source: source, offset: 0, length: 3)),
            Token(type: .identifier, lexeme: makeLexeme(source: source, offset: 4, length: 9)),
            Token(type: .equal, lexeme: makeLexeme(source: source, offset: 14, length: 1)),
            Token(type: .double, lexeme: makeLexeme(source: source, offset: 16, length: 2)),
            Token(type: .eof, lexeme: makeLexeme(source: source, offset: 18, length: 0)),
        ]
        var parser = Parser(tokens: tokens)

        let actual = try parser.parseStatement()!
        let expected: Statement<UnresolvedLocation> =
            .letDeclaration(
                .variable(
                    Token(
                        type: .identifier,
                        lexeme: makeLexeme(source: source, offset: 4, length: 9))),
                Token(
                    type: .equal,
                    lexeme: makeLexeme(source: source, offset: 14, length: 1)),
                .doubleLiteral(
                    Token(type: .double, lexeme: makeLexeme(source: source, offset: 16, length: 2)),
                    42))
        #expect(actual == expected)
    }

    @Test func parseFunctionDeclaration() throws {
        let source = """
func hypotenuse(a, b) {
    (a^2 + b^2)^0.5
}
"""

        let tokens: [Token] = [
            Token(type: .func, lexeme: makeLexeme(source: source, offset: 0, length: 4)),
            Token(type: .identifier, lexeme: makeLexeme(source: source, offset: 5, length: 10)),
            Token(type: .leftParen, lexeme: makeLexeme(source: source, offset: 15, length: 1)),
            Token(type: .identifier, lexeme: makeLexeme(source: source, offset: 16, length: 1)),
            Token(type: .comma, lexeme: makeLexeme(source: source, offset: 17, length: 1)),
            Token(type: .identifier, lexeme: makeLexeme(source: source, offset: 19, length: 1)),
            Token(type: .rightParen, lexeme: makeLexeme(source: source, offset: 20, length: 1)),
            Token(type: .leftBrace, lexeme: makeLexeme(source: source, offset: 22, length: 1)),

            Token(type: .leftParen, lexeme: makeLexeme(source: source, offset: 28, length: 1)),
            Token(type: .identifier, lexeme: makeLexeme(source: source, offset: 29, length: 1)),
            Token(type: .caret, lexeme: makeLexeme(source: source, offset: 30, length: 1)),
            Token(type: .double, lexeme: makeLexeme(source: source, offset: 31, length: 1)),
            Token(type: .plus, lexeme: makeLexeme(source: source, offset: 33, length: 1)),
            Token(type: .identifier, lexeme: makeLexeme(source: source, offset: 35, length: 1)),
            Token(type: .caret, lexeme: makeLexeme(source: source, offset: 36, length: 1)),
            Token(type: .double, lexeme: makeLexeme(source: source, offset: 37, length: 1)),
            Token(type: .rightParen, lexeme: makeLexeme(source: source, offset: 38, length: 1)),
            Token(type: .caret, lexeme: makeLexeme(source: source, offset: 39, length: 1)),
            Token(type: .double, lexeme: makeLexeme(source: source, offset: 40, length: 3)),

            Token(type: .rightBrace, lexeme: makeLexeme(source: source, offset: 44, length: 1)),
            Token(type: .eof, lexeme: makeLexeme(source: source, offset: 45, length: 0)),
        ]
        var parser = Parser(tokens: tokens)

        let actual = try parser.parseStatement()!
        let expected: Statement<UnresolvedLocation> =
            .functionDeclaration(
                Token(type: .identifier, lexeme: makeLexeme(source: source, offset: 5, length: 10)),
                [
                    Token(type: .identifier, lexeme: makeLexeme(source: source, offset: 16, length: 1)),
                    Token(type: .identifier, lexeme: makeLexeme(source: source, offset: 19, length: 1)),
                ],
                [],
                .binary(
                    .binary(
                        .binary(
                            .variable(
                                Token(type: .identifier, lexeme: makeLexeme(source: source, offset: 29, length: 1)),
                                UnresolvedLocation()),
                            Token(type: .caret, lexeme: makeLexeme(source: source, offset: 30, length: 1)),
                            .doubleLiteral(
                                Token(type: .double, lexeme: makeLexeme(source: source, offset: 31, length: 1)),
                                2)),
                        Token(type: .plus, lexeme: makeLexeme(source: source, offset: 33, length: 1)),
                        .binary(
                            .variable(
                                Token(type: .identifier, lexeme: makeLexeme(source: source, offset: 35, length: 1)),
                                UnresolvedLocation()),
                            Token(type: .caret, lexeme: makeLexeme(source: source, offset: 36, length: 1)),
                            .doubleLiteral(
                                Token(type: .double, lexeme: makeLexeme(source: source, offset: 37, length: 1)),
                                2))),
                    Token(type: .caret, lexeme: makeLexeme(source: source, offset: 39, length: 1)),
                    .doubleLiteral(
                        Token(type: .double, lexeme: makeLexeme(source: source, offset: 40, length: 3)),
                        0.5)))
        #expect(actual == expected)
    }

    @Test func parseFunctionCall() throws {
        let source = "sin(3.1415)"
        let tokens: [Token] = [
            Token(type: .identifier, lexeme: makeLexeme(source: source, offset: 0, length: 3)),
            Token(type: .leftParen, lexeme: makeLexeme(source: source, offset: 3, length: 1)),
            Token(type: .double, lexeme: makeLexeme(source: source, offset: 4, length: 6)),
            Token(type: .rightParen, lexeme: makeLexeme(source: source, offset: 10, length: 1)),
            Token(type: .eof, lexeme: makeLexeme(source: source, offset: 11, length: 0)),
        ]
        var parser = Parser(tokens: tokens)

        let actual = try parser.parseExpression()
        let expected: Expression<UnresolvedLocation> =
            .call(
                .variable(
                    Token(type: .identifier, lexeme: makeLexeme(source: source, offset: 0, length: 3)),
                    UnresolvedLocation()),
                Token(type: .leftParen, lexeme: makeLexeme(source: source, offset: 3, length: 1)),
                [
                    Expression<UnresolvedLocation>.Argument(name: nil,
                                                            value: .doubleLiteral(
                                                                Token(type: .double, lexeme: makeLexeme(source: source, offset: 4, length: 6)),
                                                                3.1415))
                ])
        #expect(actual == expected)
    }

    @Test func parseMethodCall() throws {
        let source = "Sphere().color(rgb: (1.0, 0.5, 0.7))"
        let tokens: [Token] = [
            Token(type: .identifier, lexeme: makeLexeme(source: source, offset: 0, length: 6)),
            Token(type: .leftParen, lexeme: makeLexeme(source: source, offset: 6, length: 1)),
            Token(type: .rightParen, lexeme: makeLexeme(source: source, offset: 7, length: 1)),
            Token(type: .dot, lexeme: makeLexeme(source: source, offset: 8, length: 1)),
            Token(type: .identifier, lexeme: makeLexeme(source: source, offset: 9, length: 5)),
            Token(type: .leftParen, lexeme: makeLexeme(source: source, offset: 14, length: 1)),
            Token(type: .identifier, lexeme: makeLexeme(source: source, offset: 15, length: 3)),
            Token(type: .colon, lexeme: makeLexeme(source: source, offset: 18, length: 1)),
            Token(type: .leftParen, lexeme: makeLexeme(source: source, offset: 20, length: 1)),
            Token(type: .double, lexeme: makeLexeme(source: source, offset: 21, length: 3)),
            Token(type: .comma, lexeme: makeLexeme(source: source, offset: 24, length: 1)),
            Token(type: .double, lexeme: makeLexeme(source: source, offset: 26, length: 3)),
            Token(type: .comma, lexeme: makeLexeme(source: source, offset: 29, length: 1)),
            Token(type: .double, lexeme: makeLexeme(source: source, offset: 31, length: 3)),
            Token(type: .rightParen, lexeme: makeLexeme(source: source, offset: 34, length: 1)),
            Token(type: .rightParen, lexeme: makeLexeme(source: source, offset: 35, length: 1)),
            Token(type: .eof, lexeme: makeLexeme(source: source, offset: 36, length: 0)),
        ]
        var parser = Parser(tokens: tokens)

        let actual = try parser.parseExpression()
        let expected: Expression<UnresolvedLocation> =
            .call(
                .method(
                    .call(
                        .variable(
                            Token(type: .identifier, lexeme: makeLexeme(source: source, offset: 0, length: 6)),
                            UnresolvedLocation()),
                        Token(type: .leftParen, lexeme: makeLexeme(source: source, offset: 6, length: 1)),
                        []),
                    Token(type: .identifier, lexeme: makeLexeme(source: source, offset: 9, length: 5)),
                    []),
                Token(type: .leftParen, lexeme: makeLexeme(source: source, offset: 14, length: 1)),
                [
                    Expression<UnresolvedLocation>.Argument(
                        name: Token(type: .identifier, lexeme: makeLexeme(source: source, offset: 15, length: 3)),
                        value: .tuple3(
                            Token(type: .leftParen, lexeme: makeLexeme(source: source, offset: 20, length: 1)),
                            .doubleLiteral(
                                Token(type: .double, lexeme: makeLexeme(source: source, offset: 21, length: 3)),
                                1.0),
                            .doubleLiteral(
                                Token(type: .double, lexeme: makeLexeme(source: source, offset: 26, length: 3)),
                                0.5),
                            .doubleLiteral(
                                Token(type: .double, lexeme: makeLexeme(source: source, offset: 31, length: 3)),
                                0.7)))
                ])
        #expect(actual == expected)
    }

    @Test func parseLambdaExpression() throws {
        let source = "{ u, v in cos(u)*sin(v) }"
        let tokens: [Token] = [
            Token(type: .leftBrace, lexeme: makeLexeme(source: source, offset: 0, length: 1)),
            Token(type: .identifier, lexeme: makeLexeme(source: source, offset: 2, length: 1)),
            Token(type: .comma, lexeme: makeLexeme(source: source, offset: 3, length: 1)),
            Token(type: .identifier, lexeme: makeLexeme(source: source, offset: 5, length: 1)),
            Token(type: .in, lexeme: makeLexeme(source: source, offset: 7, length: 2)),
            Token(type: .identifier, lexeme: makeLexeme(source: source, offset: 10, length: 3)),
            Token(type: .leftParen, lexeme: makeLexeme(source: source, offset: 13, length: 1)),
            Token(type: .identifier, lexeme: makeLexeme(source: source, offset: 14, length: 1)),
            Token(type: .rightParen, lexeme: makeLexeme(source: source, offset: 15, length: 1)),
            Token(type: .star, lexeme: makeLexeme(source: source, offset: 15, length: 3)),
            Token(type: .identifier, lexeme: makeLexeme(source: source, offset: 18, length: 1)),
            Token(type: .leftParen, lexeme: makeLexeme(source: source, offset: 19, length: 1)),
            Token(type: .identifier, lexeme: makeLexeme(source: source, offset: 20, length: 1)),
            Token(type: .rightParen, lexeme: makeLexeme(source: source, offset: 21, length: 1)),
            Token(type: .rightBrace, lexeme: makeLexeme(source: source, offset: 23, length: 1)),
            Token(type: .eof, lexeme: makeLexeme(source: source, offset: 24, length: 0)),
        ]
        var parser = Parser(tokens: tokens)

        let actual = try parser.parseExpression()
        let expected: Expression<UnresolvedLocation> =
            .lambda(
                Token(type: .leftBrace, lexeme: makeLexeme(source: source, offset: 0, length: 1)),
                [
                    Token(type: .identifier, lexeme: makeLexeme(source: source, offset: 2, length: 1)),
                    Token(type: .identifier, lexeme: makeLexeme(source: source, offset: 5, length: 1)),
                ],
                [],
                .binary(
                    .call(
                        .variable(
                            Token(
                                type: .identifier,
                                lexeme: makeLexeme(source: source, offset: 10, length: 3)),
                            UnresolvedLocation()),
                        Token(
                            type: .leftParen,
                            lexeme: makeLexeme(source: source, offset: 13, length: 1)),
                        [
                            Expression<UnresolvedLocation>.Argument(
                                name: nil,
                                value: .variable(
                                    Token(
                                        type: .identifier,
                                        lexeme: makeLexeme(source: source, offset: 14, length: 1)),
                                    UnresolvedLocation()))
                        ]),
                    Token(type: .star, lexeme: makeLexeme(source: source, offset: 15, length: 3)),
                    .call(
                        .variable(
                            Token(
                                type: .identifier,
                                lexeme: makeLexeme(source: source, offset: 18, length: 1)),
                            UnresolvedLocation()),
                        Token(
                            type: .leftParen,
                            lexeme: makeLexeme(source: source, offset: 19, length: 1)),
                        [
                            Expression<UnresolvedLocation>.Argument(
                                name: nil,
                                value: .variable(
                                    Token(
                                        type: .identifier,
                                        lexeme: makeLexeme(source: source, offset: 20, length: 1)),
                                    UnresolvedLocation()))
                        ])))
        #expect(actual == expected)
    }

    @Test func parseProgram() throws {
        let source = """
let camera = Camera(
    width: 400,
    height: 400,
    viewAngle: PI/3,
    from: (0, 0, 5),
    to: (0, 0, 0),
    up: (0, 1, 0))

let lights = [
    PointLight(position: (10, 10, 10))
]

let shapes = [
    Sphere()
        .color(hsl: (0.5, 0.7, 0.8))
]

World(
    camera: camera,
    lights: lights,
    shapes: shapes)
"""
        var tokenizer = Tokenizer(source: source)
        let tokens = try! tokenizer.scanTokens()
        var parser = Parser(tokens: tokens)
        let actual = try! parser.parse()
        let expected = Program(
            statements: [
                .letDeclaration(
                    .variable(
                        Token(
                            type: .identifier,
                            lexeme: makeLexeme(source: source, offset: 4, length: 6))),
                    Token(
                        type: .equal,
                        lexeme: makeLexeme(source: source, offset: 11, length: 1)),
                    .call(
                        .variable(
                            Token(
                                type: .identifier,
                                lexeme: makeLexeme(source: source, offset: 13, length: 6)),
                            UnresolvedLocation()),
                        Token(
                            type: .leftParen,
                            lexeme: makeLexeme(source: source, offset: 19, length: 1)),
                        [
                            Expression<UnresolvedLocation>.Argument(
                                name: Token(
                                    type: .identifier,
                                    lexeme: makeLexeme(source: source, offset: 25, length: 5)),
                                value: .doubleLiteral(
                                    Token(
                                        type: .double,
                                        lexeme: makeLexeme(source: source, offset: 32, length: 3)),
                                    400)),
                            Expression<UnresolvedLocation>.Argument(
                                name: Token(
                                    type: .identifier,
                                    lexeme: makeLexeme(source: source, offset: 41, length: 6)),
                                value: .doubleLiteral(
                                    Token(
                                        type: .double,
                                        lexeme: makeLexeme(source: source, offset: 49, length: 3)),
                                    400)),
                            Expression<UnresolvedLocation>.Argument(
                                name: Token(
                                    type: .identifier,
                                    lexeme: makeLexeme(source: source, offset: 58, length: 9)),
                                value: .binary(
                                    .variable(
                                        Token(
                                            type: .identifier,
                                            lexeme: makeLexeme(source: source, offset: 69, length: 2)),
                                        UnresolvedLocation()),
                                    Token(
                                        type: .slash,
                                        lexeme: makeLexeme(source: source, offset: 71, length: 1)),
                                    .doubleLiteral(
                                        Token(
                                            type: .double,
                                            lexeme: makeLexeme(source: source, offset: 72, length: 1)),
                                        3))),
                            Expression<UnresolvedLocation>.Argument(
                                name: Token(
                                    type: .identifier,
                                    lexeme: makeLexeme(source: source, offset: 79, length: 4)),
                                value: .tuple3(
                                    Token(
                                        type: .leftParen,
                                        lexeme: makeLexeme(source: source, offset: 85, length: 1)),
                                    .doubleLiteral(
                                        Token(
                                            type: .double,
                                            lexeme: makeLexeme(source: source, offset: 86, length: 1)),
                                        0),
                                    .doubleLiteral(
                                        Token(
                                            type: .double,
                                            lexeme: makeLexeme(source: source, offset: 89, length: 1)),
                                        0),
                                    .doubleLiteral(
                                        Token(
                                            type: .double,
                                            lexeme: makeLexeme(source: source, offset: 92, length: 1)),
                                        5))),
                            Expression<UnresolvedLocation>.Argument(
                                name: Token(
                                    type: .identifier,
                                    lexeme: makeLexeme(source: source, offset: 100, length: 2)),
                                value: .tuple3(
                                    Token(
                                        type: .leftParen,
                                        lexeme: makeLexeme(source: source, offset: 104, length: 1)),
                                    .doubleLiteral(
                                        Token(
                                            type: .double,
                                            lexeme: makeLexeme(source: source, offset: 105, length: 1)),
                                        0),
                                    .doubleLiteral(
                                        Token(
                                            type: .double,
                                            lexeme: makeLexeme(source: source, offset: 108, length: 1)),
                                        0),
                                    .doubleLiteral(
                                        Token(
                                            type: .double,
                                            lexeme: makeLexeme(source: source, offset: 111, length: 1)),
                                        0))),
                            Expression<UnresolvedLocation>.Argument(
                                name: Token(
                                    type: .identifier,
                                    lexeme: makeLexeme(source: source, offset: 119, length: 2)),
                                value: .tuple3(
                                    Token(
                                        type: .leftParen,
                                        lexeme: makeLexeme(source: source, offset: 123, length: 1)),
                                    .doubleLiteral(
                                        Token(
                                            type: .double,
                                            lexeme: makeLexeme(source: source, offset: 124, length: 1)),
                                        0),
                                    .doubleLiteral(
                                        Token(
                                            type: .double,
                                            lexeme: makeLexeme(source: source, offset: 127, length: 1)),
                                        1),
                                    .doubleLiteral(
                                        Token(
                                            type: .double,
                                            lexeme: makeLexeme(source: source, offset: 130, length: 1)),
                                        0))),
                        ])),
                .letDeclaration(
                    .variable(
                        Token(
                            type: .identifier,
                            lexeme: makeLexeme(source: source, offset: 139, length: 6))),
                    Token(
                        type: .equal,
                        lexeme: makeLexeme(source: source, offset: 146, length: 1)),
                    .list(
                        Token(
                            type: .leftBracket,
                            lexeme: makeLexeme(source: source, offset: 148, length: 1)),
                        [
                            .call(
                                .variable(
                                    Token(
                                        type: .identifier,
                                        lexeme: makeLexeme(source: source, offset: 154, length: 10)),
                                    UnresolvedLocation()),
                                Token(
                                    type: .leftParen,
                                    lexeme: makeLexeme(source: source, offset: 164, length: 1)),
                                [
                                    Expression<UnresolvedLocation>.Argument(
                                        name: Token(
                                            type: .identifier,
                                            lexeme: makeLexeme(source: source, offset: 165, length: 8)),
                                        value: .tuple3(
                                            Token(
                                                type: .leftParen,
                                                lexeme: makeLexeme(source: source, offset: 175, length: 1)),
                                            .doubleLiteral(
                                                Token(
                                                    type: .double,
                                                    lexeme: makeLexeme(source: source, offset: 176, length: 2)),
                                                10),
                                            .doubleLiteral(
                                                Token(
                                                    type: .double,
                                                    lexeme: makeLexeme(source: source, offset: 180, length: 2)),
                                                10),
                                            .doubleLiteral(
                                                Token(
                                                    type: .double,
                                                    lexeme: makeLexeme(source: source, offset: 184, length: 2)),
                                                10)))
                                ])
                        ])),
                .letDeclaration(
                    .variable(
                        Token(
                            type: .identifier,
                            lexeme: makeLexeme(source: source, offset: 196, length: 6))),
                    Token(
                        type: .equal,
                        lexeme: makeLexeme(source: source, offset: 203, length: 1)),
                    .list(
                        Token(
                            type: .leftBracket,
                            lexeme: makeLexeme(source: source, offset: 205, length: 1)),
                        [
                            .call(
                                .method(
                                    .call(
                                        .variable(
                                            Token(
                                                type: .identifier,
                                                lexeme: makeLexeme(source: source, offset: 211, length: 6)),
                                            UnresolvedLocation()),
                                        Token(
                                            type: .leftParen,
                                            lexeme: makeLexeme(source: source, offset: 217, length: 1)),
                                        []),
                                    Token(
                                        type: .identifier,
                                        lexeme: makeLexeme(source: source, offset: 229, length: 5)),
                                    []),
                                Token(
                                    type: .leftParen,
                                    lexeme: makeLexeme(source: source, offset: 234, length: 1)),
                                [
                                    Expression<UnresolvedLocation>.Argument(
                                        name: Token(
                                            type: .identifier,
                                            lexeme: makeLexeme(source: source, offset: 235, length: 3)),
                                        value: .tuple3(
                                            Token(
                                                type: .leftParen,
                                                lexeme: makeLexeme(source: source, offset: 240, length: 1)),
                                            .doubleLiteral(
                                                Token(
                                                    type: .double,
                                                    lexeme: makeLexeme(source: source, offset: 241, length: 3)),
                                                0.5),
                                            .doubleLiteral(
                                                Token(
                                                    type: .double,
                                                    lexeme: makeLexeme(source: source, offset: 246, length: 3)),
                                                0.7),
                                            .doubleLiteral(
                                                Token(
                                                    type: .double,
                                                    lexeme: makeLexeme(source: source, offset: 251, length: 3)),
                                                0.8)))
                                ])
                        ])),
            ],
            finalExpression: .call(
                .variable(
                    Token(
                        type: .identifier,
                        lexeme: makeLexeme(source: source, offset: 260, length: 5)),
                    UnresolvedLocation()),
                Token(type: .leftParen, lexeme: makeLexeme(source: source, offset: 265, length: 1)),
                [
                    Expression<UnresolvedLocation>.Argument(
                        name: Token(
                            type: .identifier,
                            lexeme: makeLexeme(source: source, offset: 271, length: 6)),
                        value: .variable(
                            Token(
                                type: .identifier,
                                lexeme: makeLexeme(source: source, offset: 279, length: 6)),
                            UnresolvedLocation())),
                    Expression<UnresolvedLocation>.Argument(
                        name: Token(
                            type: .identifier,
                            lexeme: makeLexeme(source: source, offset: 291, length: 6)),
                        value: .variable(
                            Token(
                                type: .identifier,
                                lexeme: makeLexeme(source: source, offset: 299, length: 6)),
                            UnresolvedLocation())),
                    Expression<UnresolvedLocation>.Argument(
                        name: Token(
                            type: .identifier,
                            lexeme: makeLexeme(source: source, offset: 311, length: 6)),
                        value: .variable(
                            Token(
                                type: .identifier,
                                lexeme: makeLexeme(source: source, offset: 319, length: 6)),
                            UnresolvedLocation())),
                ])
        )

        #expect(actual == expected)
    }
}
