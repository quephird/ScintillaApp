//
//  Helpers.swift
//  ScintillaApp
//
//  Created by Danielle Kefford on 2/18/25.
//

@testable import ScintillaApp

public func makeLexeme(source: String, offset: Int, length: Int) -> Substring {
    let startIndex = source.index(source.startIndex, offsetBy: offset)
    let endIndex = source.index(startIndex, offsetBy: length)
    return source[startIndex..<endIndex]
}

public func resolveStatement(source: String) throws -> Statement<ResolvedLocation> {
    var tokenizer = Tokenizer(source: source)
    let tokens = try tokenizer.scanTokens()
    var parser = Parser(tokens: tokens)
    let parsedStatement = try parser.parseStatement()!
    var resolver = Resolver()

    return try resolver.resolve(statement: parsedStatement)
}

public func resolveExpression(source: String) throws -> Expression<ResolvedLocation> {
    var tokenizer = Tokenizer(source: source)
    let tokens = try tokenizer.scanTokens()
    var parser = Parser(tokens: tokens)
    let parsedExpression = try parser.parseExpression()
    var resolver = Resolver()

    return try resolver.resolve(expression: parsedExpression)
}

public func resolveProgram(source: String) throws -> Program<ResolvedLocation> {
    var tokenizer = Tokenizer(source: source)
    let tokens = try tokenizer.scanTokens()
    var parser = Parser(tokens: tokens)
    let parsedProgram = try parser.parse()
    var resolver = Resolver()

    return try resolver.resolve(program: parsedProgram)
}
