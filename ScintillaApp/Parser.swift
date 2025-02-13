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

    private var nextToken: Token? {
        if cursor < tokens.count - 1 {
            return tokens[cursor + 1]
        }

        return nil
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
    mutating func parse() throws -> Program<UnresolvedLocation> {
        var statements: [Statement<UnresolvedLocation>] = []
        while let statement = try parseStatement() {
            statements.append(statement)
        }

        let finalExpression = try parseExpression()

        return Program(statements: statements, finalExpression: finalExpression)
    }

    // Scintilla programs are parsed in the following order:
    //
    //    program        → statement* expression EOF ;
    //    statement      → letDecl
    //                   | funDecl ;
    //    letDecl        → "let" IDENTIFIER "=" expression ;
    //    funDecl        → "func" IDENTIFIER "(" argList ")" "{" letDecl* expression "}" ;
    //    argList        → IDENTIFIER ("," IDENTIFIER)*
    //    expression     → term ;
    //    term           → factor ( ( "-" | "+" ) factor )* ;
    //    factor         → exponent ( ( "/" | "*" ) exponent )* ;
    //    exponent       → unary ( ( "^" unary )* ;
    //    unary          → ( "!" | "-" | "*" ) unary
    //                   | postfix ;
    //    postfix        → primary | method | call ;
    //    method         → postfix "." IDENTIFIER ;
    //    call           → postfix "(" ( (IDENTIFIER ":")? expression)* ")" ;
    //    primary        → tuple
    //                   | grouping
    //                   | list
    //                   | double
    //                   | IDENTIFIER
    //                   | lambda ;
    //    tuple          → "(" expression ( "," expression )* ")" ;
    //    grouping       → "(" expression ")" ;
    //    list           → "[" expression ( "," expression )* "]" ;
    //    lambda         → "{" argList "in" expression "}" ;

    mutating func parseStatement() throws -> Statement<UnresolvedLocation>? {
        if let letDecl = try parseLetDeclaration() {
            return letDecl
        }

        if let funDecl = try parseFunctionDeclaration() {
            return funDecl
        }

        return nil
    }

    mutating private func parseLetDeclaration() throws -> Statement<UnresolvedLocation>? {
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

    mutating private func parseFunctionDeclaration() throws -> Statement<UnresolvedLocation>? {
        guard currentTokenMatchesAny(types: [.func]) else {
            return nil
        }

        guard let funcName = consumeToken(type: .identifier) else {
            throw ParseError.missingFunctionName(currentToken)
        }

        guard currentTokenMatchesAny(types: [.leftParen]) else {
            throw ParseError.missingLeftParen(currentToken)
        }

        var argumentNames: [Token] = []
        repeat {
            guard let argumentName = consumeToken(type: .identifier) else {
                throw ParseError.missingIdentifier(currentToken)
            }

            argumentNames.append(argumentName)
        } while currentTokenMatchesAny(types: [.comma])

        guard currentTokenMatchesAny(types: [.rightParen]) else {
            throw ParseError.missingRightParen(currentToken)
        }

        guard currentTokenMatchesAny(types: [.leftBrace]) else {
            throw ParseError.missingLeftBrace(currentToken)
        }

        var letDecls: [Statement<UnresolvedLocation>] = []
        while let letDecl = try parseLetDeclaration() {
            letDecls.append(letDecl)
        }

        let returnExpr = try parseExpression()

        guard currentTokenMatchesAny(types: [.rightBrace]) else {
            throw ParseError.missingRightBrace(currentToken)
        }

        return .functionDeclaration(funcName, argumentNames, letDecls, returnExpr)
    }

    mutating private func parseExpression() throws -> Expression<UnresolvedLocation> {
        return try parseTerm()
    }

    mutating private func parseTerm() throws -> Expression<UnresolvedLocation> {
        var expr = try parseFactor()

        while currentTokenMatchesAny(types: [.plus, .minus]) {
            let oper = previousToken
            let rightExpr = try parseFactor()
            expr = .binary(expr, oper, rightExpr)
        }

        return expr
    }

    mutating private func parseFactor() throws -> Expression<UnresolvedLocation> {
        var expr = try parseExponent()

        while currentTokenMatchesAny(types: [.slash, .star]) {
            let oper = previousToken
            let rightExpr = try parseExponent()
            expr = .binary(expr, oper, rightExpr)
        }

        return expr
    }

    mutating private func parseExponent() throws -> Expression<UnresolvedLocation> {
        var expr = try parseUnary()

        while currentTokenMatchesAny(types: [.caret]) {
            let oper = previousToken
            let rightExpr = try parseUnary()
            expr = .binary(expr, oper, rightExpr)
        }

        return expr
    }

    mutating private func parseUnary() throws -> Expression<UnresolvedLocation> {
        // NOTA BENE: For the time being, the only unary expression allowed is
        // one that involves a single minus sign.
        if currentTokenMatchesAny(types: [.minus]) {
            let oper = previousToken
            let expr = try parseExpression()
            return .unary(oper, expr)
        }

        return try parsePostfix()
    }

    mutating private func parsePostfix() throws -> Expression<UnresolvedLocation> {
        var primary = try parsePrimary()

        while true {
            if let method = try parseMethod(calleeExpr: primary) {
                primary = method
                continue
            }

            if let call = try parseCall(calleeExpr: primary) {
                primary = call
                continue
            }

            break
        }

        return primary
    }

    mutating private func parseMethod(calleeExpr: Expression<UnresolvedLocation>) throws -> Expression<UnresolvedLocation>? {
        guard currentTokenMatchesAny(types: [.dot]) else {
            return nil
        }

        guard let methodName = consumeToken(type: .identifier) else {
            throw ParseError.missingIdentifier(currentToken)
        }

        return .method(calleeExpr, methodName, [])
    }

    mutating private func parseCall(calleeExpr: Expression<UnresolvedLocation>) throws -> Expression<UnresolvedLocation>? {
        guard let leftParen = consumeToken(type: .leftParen) else {
            return nil
        }

        let arguments = try parseArguments()

        guard currentTokenMatchesAny(types: [.rightParen]) else {
            throw ParseError.missingRightParen(currentToken)
        }

        return .call(calleeExpr, leftParen, arguments)
    }

    mutating private func parsePrimary() throws -> Expression<UnresolvedLocation> {
        if let tupleOrGrouping = try parseTupleOrGrouping() {
            return tupleOrGrouping
        }

        if let list = try parseList() {
            return list
        }

        if currentTokenMatchesAny(types: [.false]) {
            return .boolLiteral(previousToken, false)
        }

        if currentTokenMatchesAny(types: [.true]) {
            return .boolLiteral(previousToken, true)
        }

        if let number = consumeToken(type: .double) {
            let value = Double(number.lexeme)!
            return .doubleLiteral(previousToken, value)
        }

        if let lambda = try parseLambda() {
            return lambda
        }

        if let varName = consumeToken(type: .identifier) {
            return .variable(varName, UnresolvedLocation())
        }

        throw ParseError.expectedExpression(currentToken)
    }

    mutating private func parseTupleOrGrouping() throws -> Expression<UnresolvedLocation>? {
        guard let leftParen = consumeToken(type: .leftParen) else {
            return nil
        }

        let expr0 = try parseExpression()

        // NOTA BENE: A tuple with one component is going to be parsed
        // as a single grouped expression
        if currentTokenMatchesAny(types: [.rightParen]) {
            return expr0
        }

        guard currentTokenMatchesAny(types: [.comma]) else {
            throw ParseError.missingComma(currentToken)
        }

        let expr1 = try parseExpression()

        if currentTokenMatches(type: .rightParen) {
            let _ = consumeToken(type: .rightParen)
            return .tuple2(leftParen, expr0, expr1)
        }

        guard currentTokenMatchesAny(types: [.comma]) else {
            throw ParseError.missingComma(currentToken)
        }

        let expr2 = try parseExpression()

        guard currentTokenMatchesAny(types: [.rightParen]) else {
            throw ParseError.missingRightParen(currentToken)
        }

        return .tuple3(leftParen, expr0, expr1, expr2)
    }

    mutating private func parseList() throws -> Expression<UnresolvedLocation>? {
        guard let leftBracket = consumeToken(type: .leftBracket) else {
            return nil
        }

        var exprList: [Expression<UnresolvedLocation>] = []
        repeat {
            let newExpr = try parseExpression()
            exprList.append(newExpr)
        } while currentTokenMatchesAny(types: [.comma])

        guard currentTokenMatchesAny(types: [.rightBracket]) else {
            throw ParseError.missingRightBracket(currentToken)
        }

        return .list(leftBracket, exprList)
    }

    mutating private func parseLambda() throws -> Expression<UnresolvedLocation>? {
        guard let leftBrace = consumeToken(type: .leftBrace) else {
            return nil
        }

        var argumentNames: [Token] = []
        repeat {
            guard let argumentName = consumeToken(type: .identifier) else {
                throw ParseError.missingIdentifier(currentToken)
            }

            argumentNames.append(argumentName)
        } while currentTokenMatchesAny(types: [.comma])

        guard currentTokenMatchesAny(types: [.in]) else {
            throw ParseError.missingIn(currentToken)
        }

        let expression = try parseExpression()

        guard currentTokenMatchesAny(types: [.rightBrace]) else {
            throw ParseError.missingRightBrace(currentToken)
        }

        return .lambda(leftBrace, argumentNames, expression)
    }

    mutating private func parseArguments() throws -> [Expression<UnresolvedLocation>.Argument] {
        var arguments: [Expression<UnresolvedLocation>.Argument] = []
        if currentToken.type != .rightParen {
            repeat {
                var argName: Token? = nil
                if case .colon? = nextToken?.type,
                   let consumedToken = consumeToken(type: .identifier) {
                    argName = consumedToken

                    guard currentTokenMatchesAny(types: [.colon]) else {
                        throw ParseError.missingColon(currentToken)
                    }
                }

                let argValue = try parseExpression()
                let newArgument = Expression<UnresolvedLocation>.Argument(name: argName, value: argValue)
                arguments.append(newArgument)
            } while currentTokenMatchesAny(types: [.comma])
        }

        return arguments
    }
}
