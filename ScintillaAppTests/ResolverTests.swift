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
                .variable(
                    Token(
                        type: .identifier,
                        lexeme: makeLexeme(source: source, offset: 4, length: 6))),
                Token(
                    type: .equal,
                    lexeme: makeLexeme(source: source, offset: 11, length: 1)),
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
                Token(
                    type: .identifier,
                    lexeme: makeLexeme(source: source, offset: 5, length: 10)),
                [
                    Parameter(
                        name: Token(
                            type: .identifier,
                            lexeme: makeLexeme(source: source, offset: 16, length: 1)),
                        pattern: .variable(
                            Token(
                                type: .identifier,
                                lexeme: makeLexeme(source: source, offset: 16, length: 1)))),
                    Parameter(
                        name: Token(
                            type: .identifier,
                            lexeme: makeLexeme(source: source, offset: 19, length: 1)),
                        pattern: .variable(
                            Token(
                                type: .identifier,
                                lexeme: makeLexeme(source: source, offset: 19, length: 1)))),
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

    @Test func resolveFunctionDeclarationWithDestructuring() throws {
        let source = """
func foo(a, (b, c) as d) {
    a + b
}
"""
        let actual = try resolveStatement(source: source)
        let expected: Statement<ResolvedLocation> =
            .functionDeclaration(
                Token(
                    type: .identifier,
                    lexeme: makeLexeme(source: source, offset: 5, length: 3)),
                [
                    Parameter(
                        name: Token(
                            type: .identifier,
                            lexeme: makeLexeme(source: source, offset: 9, length: 1)),
                        pattern: .variable(
                            Token(
                                type: .identifier,
                                lexeme: makeLexeme(source: source, offset: 9, length: 1)))),
                    Parameter(
                        name: Token(
                            type: .identifier,
                            lexeme: makeLexeme(source: source, offset: 22, length: 1)),
                        pattern: .tuple2(
                            .variable(
                                Token(
                                    type: .identifier,
                                    lexeme: makeLexeme(source: source, offset: 13, length: 1))),
                            .variable(
                                Token(
                                    type: .identifier,
                                    lexeme: makeLexeme(source: source, offset: 16, length: 1))))),
                ],
                [],
                .binary(
                    .variable(
                        Token(
                            type: .identifier,
                            lexeme: makeLexeme(source: source, offset: 31, length: 1)),
                        ResolvedLocation(depth: 0, index: 0)),
                    Token(
                        type: .plus,
                        lexeme: makeLexeme(source: source, offset: 33, length: 1)),
                    .variable(
                        Token(
                            type: .identifier,
                            lexeme: makeLexeme(source: source, offset: 35, length: 1)),
                        ResolvedLocation(depth: 0, index: 2))))
        #expect(actual == expected)
    }

    @Test func resolveLambdaExpression() throws {
        let source = "{ x, y, z in x + y + z - 1 }"
        let actual = try resolveExpression(source: source)
        let expected: Expression<ResolvedLocation> =
            .lambda(
                Token(type: .leftBrace, lexeme: makeLexeme(source: source, offset: 0, length: 1)),
                [
                    Parameter(
                        name: nil,
                        pattern: .variable(
                            Token(
                                type: .identifier,
                                lexeme: makeLexeme(source: source, offset: 2, length: 1)))),
                    Parameter(
                        name: nil,
                        pattern: .variable(
                            Token(
                                type: .identifier,
                                lexeme: makeLexeme(source: source, offset: 5, length: 1)))),
                    Parameter(
                        name: nil,
                        pattern: .variable(
                            Token(
                                type: .identifier,
                                lexeme: makeLexeme(source: source, offset: 8, length: 1)))),
                ],
                [],
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

    @Test func resolveLambdaExpressionWithDestructuring() throws {
        let source = "{ a, (b, c) in a + b + c }"
        let actual = try resolveExpression(source: source)
        let expected: Expression<ResolvedLocation> =
            .lambda(
                Token(type: .leftBrace, lexeme: makeLexeme(source: source, offset: 0, length: 1)),
                [
                    Parameter(
                        name: nil,
                        pattern: .variable(
                            Token(
                                type: .identifier,
                                lexeme: makeLexeme(source: source, offset: 2, length: 1)))),
                    Parameter(
                        name: nil,
                        pattern: .tuple2(
                            .variable(
                                Token(
                                    type: .identifier,
                                    lexeme: makeLexeme(source: source, offset: 6, length: 1))),
                            .variable(
                                Token(
                                    type: .identifier,
                                    lexeme: makeLexeme(source: source, offset: 9, length: 1)))))
                ],
                [],
                .binary(
                    .binary(
                        .variable(
                            Token(
                                type: .identifier,
                                lexeme: makeLexeme(source: source, offset: 15, length: 1)),
                            ResolvedLocation(depth: 0, index: 0)),
                        Token(
                            type: .plus,
                            lexeme: makeLexeme(source: source, offset: 17, length: 1)),
                        .variable(
                            Token(
                                type: .identifier,
                                lexeme: makeLexeme(source: source, offset: 19, length: 1)),
                            ResolvedLocation(depth: 0, index: 1))),
                    Token(
                        type: .plus,
                        lexeme: makeLexeme(source: source, offset: 21, length: 1)),
                    .variable(
                        Token(
                            type: .identifier,
                            lexeme: makeLexeme(source: source, offset: 23, length: 1)),
                        ResolvedLocation(depth: 0, index: 2))))
        #expect(actual == expected)
    }

    @Test func resolveMinimalProgram() throws {
        let source = """
let camera = Camera(
    width: 400,
    height: 400,
    viewAngle: pi/3,
    from: (0, 0, 5),
    to: (0, 0, 0),
    up: (0, 1, 0))

let lights = [
    PointLight(position: (10, 10, 10))
]

let turquoise = Uniform(
    Color(h: 0.5, s: 0.7, l: 0.8))

let shapes = [
    Sphere()
        .material(turquoise)
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
                    .variable(
                        Token(
                            type: .identifier,
                            lexeme: makeLexeme(source: source, offset: 4, length: 6))),
                    Token(
                        type: .equal,
                        lexeme: makeLexeme(source: source, offset: 11, length: 1)),
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
                            ResolvedLocation(depth: 0, index: 17)),
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
                                        ResolvedLocation(depth: 0, index: 80)),
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
                                .function(
                                    Token(
                                        type: .identifier,
                                        lexeme: makeLexeme(source: source, offset: 154, length: 10)),
                                    [
                                        Token(
                                            type: .identifier,
                                            lexeme: makeLexeme(source: source, offset: 165, length: 8)),
                                    ],
                                    ResolvedLocation(depth: 0, index: 18)),
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
                    .variable(
                        Token(
                            type: .identifier,
                            lexeme: makeLexeme(source: source, offset: 196, length: 9))),
                    Token(
                        type: .equal,
                        lexeme: makeLexeme(source: source, offset: 206, length: 1)),
                    .call(
                        .function(
                            Token(
                                type: .identifier,
                                lexeme: makeLexeme(source: source, offset: 208, length: 7)),
                            [nil],
                            ResolvedLocation(depth: 0, index: 30)),
                        Token(
                            type: .leftParen,
                            lexeme: makeLexeme(source: source, offset: 215, length: 1)),
                        [
                            Expression<ResolvedLocation>.Argument(
                                name: nil,
                                value: .call(
                                    .function(
                                        Token(
                                            type: .identifier,
                                            lexeme: makeLexeme(source: source, offset: 221, length: 5)),
                                        [
                                            Token(
                                                type: .identifier,
                                                lexeme: makeLexeme(source: source, offset: 227, length: 1)),
                                            Token(
                                                type: .identifier,
                                                lexeme: makeLexeme(source: source, offset: 235, length: 1)),
                                            Token(
                                                type: .identifier,
                                                lexeme: makeLexeme(source: source, offset: 243, length: 1)),
                                        ],
                                        ResolvedLocation(depth: 0, index: 1)),
                                    Token(
                                        type: .leftParen,
                                        lexeme: makeLexeme(source: source, offset: 226, length: 1)),
                                    [
                                        Expression<ResolvedLocation>.Argument(
                                            name: Token(
                                                type: .identifier,
                                                lexeme: makeLexeme(source: source, offset: 227, length: 1)),
                                            value: .doubleLiteral(
                                                Token(
                                                    type: .double,
                                                    lexeme: makeLexeme(source: source, offset: 230, length: 3)),
                                                0.5)),
                                        Expression<ResolvedLocation>.Argument(
                                            name: Token(
                                                type: .identifier,
                                                lexeme: makeLexeme(source: source, offset: 235, length: 1)),
                                            value: .doubleLiteral(
                                                Token(
                                                    type: .double,
                                                    lexeme: makeLexeme(source: source, offset: 238, length: 3)),
                                                0.7)),
                                        Expression<ResolvedLocation>.Argument(
                                            name: Token(
                                                type: .identifier,
                                                lexeme: makeLexeme(source: source, offset: 243, length: 1)),
                                            value: .doubleLiteral(
                                                Token(
                                                    type: .double,
                                                    lexeme: makeLexeme(source: source, offset: 246, length: 3)),
                                                0.8)),
                                    ]))
                        ])),
                .letDeclaration(
                    .variable(
                        Token(
                            type: .identifier,
                            lexeme: makeLexeme(source: source, offset: 257, length: 6))),
                    Token(
                        type: .equal,
                        lexeme: makeLexeme(source: source, offset: 264, length: 1)),
                    .list(
                        Token(
                            type: .leftBracket,
                            lexeme: makeLexeme(source: source, offset: 266, length: 1)),
                        [
                            .call(
                                .method(
                                    .call(
                                        .function(
                                            Token(
                                                type: .identifier,
                                                lexeme: makeLexeme(source: source, offset: 272, length: 6)),
                                            [],
                                            ResolvedLocation(depth: 0, index: 12)),
                                        Token(
                                            type: .leftParen,
                                            lexeme: makeLexeme(source: source, offset: 278, length: 1)),
                                        []),
                                    Token(
                                        type: .identifier,
                                        lexeme: makeLexeme(source: source, offset: 290, length: 8)),
                                    [nil]),
                                Token(
                                    type: .leftParen,
                                    lexeme: makeLexeme(source: source, offset: 298, length: 1)),
                                [
                                    Expression<ResolvedLocation>.Argument(
                                        name: nil,
                                        value: .variable(
                                            Token(
                                                type: .identifier,
                                                lexeme: makeLexeme(source: source, offset: 299, length: 9)),
                                            ResolvedLocation(depth: 0, index: 83)))
                                ])
                        ])),
            ],
            finalExpression: .call(
                .function(
                    Token(
                        type: .identifier,
                        lexeme: makeLexeme(source: source, offset: 313, length: 5)),
                    [
                        Token(
                            type: .identifier,
                            lexeme: makeLexeme(source: source, offset: 324, length: 6)),
                        Token(
                            type: .identifier,
                            lexeme: makeLexeme(source: source, offset: 344, length: 6)),
                        Token(
                            type: .identifier,
                            lexeme: makeLexeme(source: source, offset: 364, length: 6)),
                    ],
                    ResolvedLocation(depth: 0, index: 16)),
                Token(
                    type: .leftParen,
                    lexeme: makeLexeme(source: source, offset: 318, length: 1)),
                [
                    Expression<ResolvedLocation>.Argument(
                        name: Token(
                            type: .identifier,
                            lexeme: makeLexeme(source: source, offset: 324, length: 6)),
                        value: .variable(
                            Token(
                                type: .identifier,
                                lexeme: makeLexeme(source: source, offset: 332, length: 6)),
                            ResolvedLocation(depth: 0, index: 81))),
                    Expression<ResolvedLocation>.Argument(
                        name: Token(
                            type: .identifier,
                            lexeme: makeLexeme(source: source, offset: 344, length: 6)),
                        value: .variable(
                            Token(
                                type: .identifier,
                                lexeme: makeLexeme(source: source, offset: 352, length: 6)),
                            ResolvedLocation(depth: 0, index: 82))),
                    Expression<ResolvedLocation>.Argument(
                        name: Token(
                            type: .identifier,
                            lexeme: makeLexeme(source: source, offset: 364, length: 6)),
                        value: .variable(
                            Token(
                                type: .identifier,
                                lexeme: makeLexeme(source: source, offset: 372, length: 6)),
                            ResolvedLocation(depth: 0, index: 84))),
                ])
        )

        #expect(actual.statements == expected.statements)
        #expect(actual.finalExpression == expected.finalExpression)
    }
}
