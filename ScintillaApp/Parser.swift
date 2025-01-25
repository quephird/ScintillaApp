//
//  Parser.swift
//  ScintillaApp
//
//  Created by Danielle Kefford on 1/23/25.
//

struct Parser {
    private var tokens: [Token]
    private var cursor: Int = 0
    private var currentToken: Token {
        return tokens[cursor]
    }
    private var previousToken: Token {
        return tokens[cursor - 1]
    }

    init(tokens: [Token]) {
        self.tokens = tokens
    }
}

extension Parser {
    mutating private func advanceCursor() {
        cursor += 1
    }

    private func currentTokenMatches(type: TokenType) -> Bool {
        if currentToken.type == .eof {
            return false
        }

        return currentToken.type == type
    }

    mutating private func currentTokenMatchesAny(types: [TokenType]) -> Bool {
        for type in types {
            if currentTokenMatches(type: type) {
                advanceCursor()
                return true
            }
        }

        return false
    }

    mutating private func consumeToken(type: TokenType) -> Token? {
        guard currentTokenMatches(type: type) else {
            return nil
        }

        advanceCursor()
        return previousToken
    }
}

extension Parser {
    mutating func parse() throws -> [Statement<UnresolvedDepth>] {
        var statements: [Statement<UnresolvedDepth>] = []
        while currentToken.type != .eof {
            let statement = try parseStatement()
            statements.append(statement)
        }

        return statements
    }

    // Statements are parsed in the following order:
    //
    //    program        → statement* EOF ;
    //    statement      → letDecl
    //                   | expression ;
    //    letDecl        → "let" IDENTIFIER "=" expression ;
    //    expression     → term ;
    //    term           → factor ( ( "-" | "+" ) factor )* ;
    //    factor         → unary ( ( "/" | "*" | "%" ) unary )* ;
    //    unary          → ( "!" | "-" | "*" ) unary
    //                   | postfix ;
    //    postfix        → primary
    //                   | constructor
    //    constructor    → IDENTIFIER ( (IDENTIFIER : expression)* ) ;
    //    primary        → tuple
    //                   | list
    //                   | double
    //                   | IDENTIFIER ;

    mutating func parseStatement() throws -> Statement<UnresolvedDepth> {
        if let letDecl = try parseLetDeclaration() {
            return letDecl
        }

        let expression = try parseExpression()
        return .expression(expression)
    }

    mutating private func parseLetDeclaration() throws -> Statement<UnresolvedDepth>? {
        guard currentTokenMatchesAny(types: [.let]) else {
            return nil
        }

        guard let varName = consumeToken(type: .identifier) else {
            throw ParseError.missingVariableName(currentToken)
        }

        guard currentTokenMatchesAny(types: [.equal]) else {
            throw ParseError.missingEquals(currentToken)
        }

        let letExpr = try parseExpression()

        return .letDeclaration(varName, letExpr);
    }

    mutating private func parseExpression() throws -> Expression<UnresolvedDepth> {
        return try parseTerm()
    }

    mutating private func parseTerm() throws -> Expression<UnresolvedDepth> {
        var expr = try parseFactor()

        while currentTokenMatchesAny(types: [.plus, .minus]) {
            let oper = previousToken
            let rightExpr = try parseFactor()
            expr = .binary(expr, oper, rightExpr)
        }

        return expr
    }

    mutating private func parseFactor() throws -> Expression<UnresolvedDepth> {
        var expr = try parseUnary()

        while currentTokenMatchesAny(types: [.slash, .star, .modulus]) {
            let oper = previousToken
            let rightExpr = try parseUnary()
            expr = .binary(expr, oper, rightExpr)
        }

        return expr
    }

    mutating private func parseUnary() throws -> Expression<UnresolvedDepth> {
        // NOTA BENE: For the time being, the onky unary expression allowed is
        // one that involves a single minus sign.
        if currentTokenMatchesAny(types: [.minus]) {
            let oper = previousToken
            let expr = try parseExpression()
            return .unary(oper, expr)
        }

        return try parsePostfix()
    }

    mutating private func parsePostfix() throws -> Expression<UnresolvedDepth> {
        var expr = try parsePrimary()

        if let object = try parseConstructor(expr: expr) {
            expr = object
        }

        return expr
    }

    mutating private func parseConstructor(expr: Expression<UnresolvedDepth>) throws -> Expression<UnresolvedDepth>? {
        guard let leftParen = consumeToken(type: .leftParen) else {
            return nil
        }

        var argList: [Expression<UnresolvedDepth>.Argument] = []
        if currentToken.type != .rightParen {
            repeat {
                guard let argName = consumeToken(type: .identifier) else {
                    throw ParseError.missingIdentifier(currentToken)
                }

                guard currentTokenMatchesAny(types: [.colon]) else {
                    throw ParseError.missingColon(currentToken)
                }

                let argValue = try parseExpression()
                let newArg = Expression<UnresolvedDepth>.Argument(name: argName, value: argValue)
                argList.append(newArg)
            } while currentTokenMatchesAny(types: [.comma])
        }

        guard currentTokenMatchesAny(types: [.rightParen]) else {
            throw ParseError.missingRightParen(currentToken)
        }

        return .constructor(expr, leftParen, argList)
    }

    mutating private func parsePrimary() throws -> Expression<UnresolvedDepth> {
        if let tuple = try parseTuple() {
            return tuple
        }

        if let list = try parseList() {
            return list
        }

        if let number = consumeToken(type: .double) {
            let value = Double(number.lexeme)!
            return .literal(previousToken, .double(value))
        }

        if let varName = consumeToken(type: .identifier) {
            return .variable(varName, UnresolvedDepth())
        }

        throw ParseError.expectedExpression(currentToken)
    }

    mutating private func parseTuple() throws -> Expression<UnresolvedDepth>? {
        guard let leftParen = consumeToken(type: .leftParen) else {
            return nil
        }

        let expr0 = try parseExpression()
        guard currentTokenMatchesAny(types: [.comma]) else {
            throw ParseError.missingComma(currentToken)
        }

        let expr1 = try parseExpression()
        guard currentTokenMatchesAny(types: [.comma]) else {
            throw ParseError.missingComma(currentToken)
        }

        let expr2 = try parseExpression()

        guard currentTokenMatchesAny(types: [.rightParen]) else {
            throw ParseError.missingRightParen(currentToken)
        }

        return .tuple(leftParen, expr0, expr1, expr2)
    }

    mutating private func parseList() throws -> Expression<UnresolvedDepth>? {
        guard let leftBracket = consumeToken(type: .leftBracket) else {
            return nil
        }

        var exprList: [Expression<UnresolvedDepth>] = []
        repeat {
            let newExpr = try parseExpression()
            exprList.append(newExpr)
        } while currentTokenMatchesAny(types: [.comma])

        guard currentTokenMatchesAny(types: [.rightBracket]) else {
            throw ParseError.missingRightBracket(currentToken)
        }

        return .list(leftBracket, exprList)
    }
}
