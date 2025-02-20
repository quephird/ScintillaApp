//
//  ResolverTests.swift
//  ScintillaApp
//
//  Created by Danielle Kefford on 2/19/25.
//

import Testing
@testable import ScintillaApp

struct ResolverTests {
    @Test func resolveNumericLiteralExpression() throws {
        let source = "42"
        let actual = try resolveExpression(source: source)
        let expected: Expression<ResolvedLocation> =
            .doubleLiteral(
                Token(type: .double, lexeme: makeLexeme(source: source, offset: 0, length: 2)),
                42)
        #expect(actual == expected)
    }

    @Test func resolveBooleanLiteralExpression() throws {
        let source = "true"
        let actual = try resolveExpression(source: source)
        let expected: Expression<ResolvedLocation> =
            .boolLiteral(
                Token(type: .true, lexeme: makeLexeme(source: source, offset: 0, length: 4)),
                true)
        #expect(actual == expected)
    }

    @Test func resolveLetDeclaration() throws {
        let source = "let answer = 42"
        let actual = try resolveStatement(source: source)
        let expected: Statement<ResolvedLocation> =
            .letDeclaration(
                Token(
                    type: .identifier,
                    lexeme: makeLexeme(source: source, offset: 4, length: 6)),
                .doubleLiteral(
                    Token(
                        type: .double,
                        lexeme: makeLexeme(source: source, offset: 13, length: 2)),
                    42))
        #expect(actual == expected)
    }

    @Test func resolveFunctionDeclaration() throws {
        let source = """
func hypotenuse(a, b) {
    (a^2 + b^2)^0.5
}
"""
        let actual = try resolveStatement(source: source)
        let expected: Statement<ResolvedLocation> =
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
                                ResolvedLocation(depth: 0, index: 0)),
                            Token(type: .caret, lexeme: makeLexeme(source: source, offset: 30, length: 1)),
                            .doubleLiteral(
                                Token(type: .double, lexeme: makeLexeme(source: source, offset: 31, length: 1)),
                                2)),
                        Token(type: .plus, lexeme: makeLexeme(source: source, offset: 33, length: 1)),
                        .binary(
                            .variable(
                                Token(type: .identifier, lexeme: makeLexeme(source: source, offset: 35, length: 1)),
                                ResolvedLocation(depth: 0, index: 1)),
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

    @Test func resolveLambdaExpression() throws {
        let source = "{ x, y, z in x + y + z - 1 }"
        let actual = try resolveExpression(source: source)
        let expected: Expression<ResolvedLocation> =
            .lambda(
                Token(type: .leftBrace, lexeme: makeLexeme(source: source, offset: 0, length: 1)),
                [
                    Token(type: .identifier, lexeme: makeLexeme(source: source, offset: 2, length: 1)),
                    Token(type: .identifier, lexeme: makeLexeme(source: source, offset: 5, length: 1)),
                    Token(type: .identifier, lexeme: makeLexeme(source: source, offset: 8, length: 1)),
                ],
                .binary(
                    .binary(
                        .binary(
                            .variable(
                                Token(
                                    type: .identifier,
                                    lexeme: makeLexeme(source: source, offset: 13, length: 1)),
                                ResolvedLocation(depth: 0, index: 0)),
                            Token(
                                type: .plus,
                                lexeme: makeLexeme(source: source, offset: 15, length: 1)),
                            .variable(
                                Token(
                                    type: .identifier,
                                    lexeme: makeLexeme(source: source, offset: 17, length: 1)),
                                ResolvedLocation(depth: 0, index: 1))),
                        Token(
                            type: .plus,
                            lexeme: makeLexeme(source: source, offset: 19, length: 1)),
                        .variable(
                            Token(
                                type: .identifier,
                                lexeme: makeLexeme(source: source, offset: 21, length: 1)),
                            ResolvedLocation(depth: 0, index: 2))),
                    Token(
                        type: .minus,
                        lexeme: makeLexeme(source: source, offset: 23, length: 1)),
                    .doubleLiteral(
                        Token(
                            type: .double,
                            lexeme: makeLexeme(source: source, offset: 25, length: 1)),
                        1)))
        #expect(actual == expected)
    }

    @Test func resolveMinimalProgram() throws {
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
        let actual = try resolveProgram(source: source)
        let expected = Program(
            statements: [
                .letDeclaration(
                    Token(
                        type: .identifier,
                        lexeme: makeLexeme(source: source, offset: 4, length: 6)),
                    .call(
                        .function(
                            Token(
                                type: .identifier,
                                lexeme: makeLexeme(source: source, offset: 13, length: 6)),
                            [
                                Token(
                                    type: .identifier,
                                    lexeme: makeLexeme(source: source, offset: 25, length: 5)),
                                Token(
                                    type: .identifier,
                                    lexeme: makeLexeme(source: source, offset: 41, length: 6)),
                                Token(
                                    type: .identifier,
                                    lexeme: makeLexeme(source: source, offset: 58, length: 9)),
                                Token(
                                    type: .identifier,
                                    lexeme: makeLexeme(source: source, offset: 79, length: 4)),
                                Token(
                                    type: .identifier,
                                    lexeme: makeLexeme(source: source, offset: 100, length: 2)),
                                Token(
                                    type: .identifier,
                                    lexeme: makeLexeme(source: source, offset: 119, length: 2)),
                            ],
                            ResolvedLocation(depth: 0, index: 15)),
                        Token(
                            type: .leftParen,
                            lexeme: makeLexeme(source: source, offset: 19, length: 1)),
                        [
                            Expression<ResolvedLocation>.Argument(
                                name: Token(
                                    type: .identifier,
                                    lexeme: makeLexeme(source: source, offset: 25, length: 5)),
                                value: .doubleLiteral(
                                    Token(
                                        type: .double,
                                        lexeme: makeLexeme(source: source, offset: 32, length: 3)),
                                    400)),
                            Expression<ResolvedLocation>.Argument(
                                name: Token(
                                    type: .identifier,
                                    lexeme: makeLexeme(source: source, offset: 41, length: 6)),
                                value: .doubleLiteral(
                                    Token(
                                        type: .double,
                                        lexeme: makeLexeme(source: source, offset: 49, length: 3)),
                                    400)),
                            Expression<ResolvedLocation>.Argument(
                                name: Token(
                                    type: .identifier,
                                    lexeme: makeLexeme(source: source, offset: 58, length: 9)),
                                value: .binary(
                                    .variable(
                                        Token(
                                            type: .identifier,
                                            lexeme: makeLexeme(source: source, offset: 69, length: 2)),
                                        ResolvedLocation(depth: 0, index: 36)),
                                    Token(
                                        type: .slash,
                                        lexeme: makeLexeme(source: source, offset: 71, length: 1)),
                                    .doubleLiteral(
                                        Token(
                                            type: .double,
                                            lexeme: makeLexeme(source: source, offset: 72, length: 1)),
                                        3))),
                            Expression<ResolvedLocation>.Argument(
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
                            Expression<ResolvedLocation>.Argument(
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
                            Expression<ResolvedLocation>.Argument(
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
                    Token(
                        type: .identifier,
                        lexeme: makeLexeme(source: source, offset: 139, length: 6)),
                    .list(
                        Token(
                            type: .leftBracket,
                            lexeme: makeLexeme(source: source, offset: 148, length: 1)),
                        [
                            .call(
                                .function(
                                    Token(
                                        type: .identifier,
                                        lexeme: makeLexeme(source: source, offset: 154, length: 10)),
                                    [
                                        Token(
                                            type: .identifier,
                                            lexeme: makeLexeme(source: source, offset: 165, length: 8)),
                                    ],
                                    ResolvedLocation(depth: 0, index: 16)),
                                Token(
                                    type: .leftParen,
                                    lexeme: makeLexeme(source: source, offset: 164, length: 1)),
                                [
                                    Expression<ResolvedLocation>.Argument(
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
                    Token(
                        type: .identifier,
                        lexeme: makeLexeme(source: source, offset: 196, length: 6)),
                    .list(
                        Token(
                            type: .leftBracket,
                            lexeme: makeLexeme(source: source, offset: 205, length: 1)),
                        [
                            .call(
                                .method(
                                    .call(
                                        .function(
                                            Token(
                                                type: .identifier,
                                                lexeme: makeLexeme(source: source, offset: 211, length: 6)),
                                            [],
                                            ResolvedLocation(depth: 0, index: 10)),
                                        Token(
                                            type: .leftParen,
                                            lexeme: makeLexeme(source: source, offset: 217, length: 1)),
                                        []),
                                    Token(
                                        type: .identifier,
                                        lexeme: makeLexeme(source: source, offset: 229, length: 5)),
                                    [
                                        Token(
                                            type: .identifier,
                                            lexeme: makeLexeme(source: source, offset: 235, length: 3)),
                                    ]),
                                Token(
                                    type: .leftParen,
                                    lexeme: makeLexeme(source: source, offset: 234, length: 1)),
                                [
                                    Expression<ResolvedLocation>.Argument(
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
                .function(
                    Token(
                        type: .identifier,
                        lexeme: makeLexeme(source: source, offset: 260, length: 5)),
                    [
                        Token(
                            type: .identifier,
                            lexeme: makeLexeme(source: source, offset: 271, length: 6)),
                        Token(
                            type: .identifier,
                            lexeme: makeLexeme(source: source, offset: 291, length: 6)),
                        Token(
                            type: .identifier,
                            lexeme: makeLexeme(source: source, offset: 311, length: 6)),
                    ],
                    ResolvedLocation(depth: 0, index: 14)),
                Token(
                    type: .leftParen,
                    lexeme: makeLexeme(source: source, offset: 265, length: 1)),
                [
                    Expression<ResolvedLocation>.Argument(
                        name: Token(
                            type: .identifier,
                            lexeme: makeLexeme(source: source, offset: 271, length: 6)),
                        value: .variable(
                            Token(
                                type: .identifier,
                                lexeme: makeLexeme(source: source, offset: 279, length: 6)),
                            ResolvedLocation(depth: 0, index: 37))),
                    Expression<ResolvedLocation>.Argument(
                        name: Token(
                            type: .identifier,
                            lexeme: makeLexeme(source: source, offset: 291, length: 6)),
                        value: .variable(
                            Token(
                                type: .identifier,
                                lexeme: makeLexeme(source: source, offset: 299, length: 6)),
                            ResolvedLocation(depth: 0, index: 38))),
                    Expression<ResolvedLocation>.Argument(
                        name: Token(
                            type: .identifier,
                            lexeme: makeLexeme(source: source, offset: 311, length: 6)),
                        value: .variable(
                            Token(
                                type: .identifier,
                                lexeme: makeLexeme(source: source, offset: 319, length: 6)),
                            ResolvedLocation(depth: 0, index: 39))),
                ])
        )

        #expect(actual.statements == expected.statements)
    }
}
