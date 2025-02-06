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
    mutating func parse() throws -> Program<UnresolvedDepth> {
        var statements: [Statement<UnresolvedDepth>] = []
        while let statement = try parseStatement() {
            statements.append(statement)
        }

        let finalExpression = try parseExpression()

        return Program(statements: statements, finalExpression: finalExpression)
    }

    // Scintilla programs are parsed in the following order:
    //
    //    program        → statement* expression EOF ;
    //    statement      → letDecl ;
    //    letDecl        → "let" IDENTIFIER "=" expression ;
    //    expression     → term ;
    //    term           → factor ( ( "-" | "+" ) factor )* ;
    //    factor         → unary ( ( "/" | "*" | "%" ) unary )* ;
    //    unary          → ( "!" | "-" | "*" ) unary
    //                   | postfix ;
    //    postfix        → primary | method | call ;
    //    method         → postfix "." IDENTIFIER ;
    //    call           → postfix "(" ( (IDENTIFIER ":")? expression)* ")" ;
    //    primary        → tuple
    //                   | list
    //                   | double
    //                   | IDENTIFIER
    //                   | lambda ;
    //    lambda         → "{" IDENTIFIER ("," IDENTIFIER)* "in" expression "}" ;

//    Cube().translate(x: 0.0, y: 2,0, z: 1.0)
//    { x, y in x + y }(1, 2)

    //    postfix        → primary ( method | call )* ;
    //    method         → "." IDENTIFIER ;
    //    call           → "(" ( (IDENTIFIER ":")? expression)* ")" ;


    mutating func parseStatement() throws -> Statement<UnresolvedDepth>? {
        if let letDecl = try parseLetDeclaration() {
            return letDecl
        }

        return nil
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

    mutating private func parseMethod(calleeExpr: Expression<UnresolvedDepth>) throws -> Expression<UnresolvedDepth>? {
        guard currentTokenMatchesAny(types: [.dot]) else {
            return nil
        }

        guard let methodName = consumeToken(type: .identifier) else {
            throw ParseError.missingIdentifier(currentToken)
        }

        return .method(calleeExpr, methodName, [])
    }

    mutating private func parseCall(calleeExpr: Expression<UnresolvedDepth>) throws -> Expression<UnresolvedDepth>? {
        guard let leftParen = consumeToken(type: .leftParen) else {
            return nil
        }

        let arguments = try parseArguments()

        guard currentTokenMatchesAny(types: [.rightParen]) else {
            throw ParseError.missingRightParen(currentToken)
        }

        return .call(calleeExpr, leftParen, arguments)
    }

    mutating private func parsePrimary() throws -> Expression<UnresolvedDepth> {
        if let tuple = try parseTuple() {
            return tuple
        }

        if let list = try parseList() {
            return list
        }

        if currentTokenMatchesAny(types: [.false]) {
            return .literal(previousToken, .boolean(false))
        }

        if currentTokenMatchesAny(types: [.true]) {
            return .literal(previousToken, .boolean(true))
        }

        if let number = consumeToken(type: .double) {
            let value = Double(number.lexeme)!
            return .literal(previousToken, .double(value))
        }

        if let lambda = try parseLambda() {
            return lambda
        }

        if let varName = consumeToken(type: .identifier) {
            return .variable(varName, UnresolvedDepth())
        }

        //        if let varName = consumeToken(type: .identifier) {
        //            if let object = try parseConstructor(name: varName) {
        //                return object
        //            }
        //
        //            return .variable(varName, UnresolvedDepth())
        //        }

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

    mutating private func parseLambda() throws -> Expression<UnresolvedDepth>? {
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

//    mutating private func parseConstructor(name: Token) throws -> Expression<UnresolvedDepth>? {
//        guard currentTokenMatchesAny(types: [.leftParen]) else {
//            return nil
//        }
//
//        let arguments = try parseArguments()
//
//        guard currentTokenMatchesAny(types: [.rightParen]) else {
//            throw ParseError.missingRightParen(currentToken)
//        }
//
//        return .function(name, arguments, UnresolvedDepth())
//    }

    mutating private func parseArguments() throws -> [Expression<UnresolvedDepth>.Argument] {
        var arguments: [Expression<UnresolvedDepth>.Argument] = []
        if currentToken.type != .rightParen {
            repeat {
                var argName: Token? = nil
                if let consumedToken = consumeToken(type: .identifier) {
                    argName = consumedToken

                    guard currentTokenMatchesAny(types: [.colon]) else {
                        throw ParseError.missingColon(currentToken)
                    }
                }

                let argValue = try parseExpression()
                let newArgument = Expression<UnresolvedDepth>.Argument(name: argName, value: argValue)
                arguments.append(newArgument)
            } while currentTokenMatchesAny(types: [.comma])
        }

        return arguments
    }
}
