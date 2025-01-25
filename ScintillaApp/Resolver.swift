//
//  Resolver.swift
//  ScintillaApp
//
//  Created by Danielle Kefford on 1/25/25.
//

struct Resolver {
    private enum ArgumentListType {
        case none
        case constructorCall
        case listInitializer
        case tupleInitializer
    }

    private var scopeStack: [[String: Bool]] = [
        [
            "PI": true,
            "Sphere": true,
            "PointLight": true,
            "Camera": true,
            "World": true,
        ]
    ]
    private var currentArgumentListType: ArgumentListType = .none
}

extension Resolver {
    // Internal helpers
    mutating private func beginScope() {
        scopeStack.append([:])
    }

    mutating private func endScope() {
        scopeStack.removeLast()
    }

    mutating private func declareVariable(variableToken: Token) throws {
        // ACHTUNG!!! Only variables declared/defined in local
        // blocks are tracked by the resolver, which is why
        // we bail here since the stack is empty in the
        // global environment.
        if scopeStack.isEmpty {
            return
        }

        if scopeStack.lastMutable.keys.contains(String(variableToken.lexeme)) {
            throw ResolverError.variableAlreadyDefined(variableToken)
        }

        scopeStack.lastMutable[String(variableToken.lexeme)] = false
    }

    mutating private func defineVariable(name: String) {
        // ACHTUNG!!! Only variables declared/defined in local
        // blocks are tracked by the resolver, which is why
        // we bail here since the stack is empty in the
        // global environment.
        if scopeStack.isEmpty {
            return
        }

        scopeStack.lastMutable[name] = true
    }

    private func getDepth(nameToken: Token) throws -> Int {
        let name = String(nameToken.lexeme)

        var i = scopeStack.count - 1
        while i >= 0 {
            if let _ = scopeStack[i][name] {
                return scopeStack.count - 1 - i
            }

            i = i - 1
        }

        // If we get here, the variable must _not_ be defined in the scope stack
        throw ResolverError.undefinedVariable(nameToken)
    }
}

extension Resolver {
    // Main point of entry
    mutating func resolve(statements: [Statement<UnresolvedDepth>]) throws -> [Statement<Int>] {
        let resolvedStatements = try statements.map { statement in
            return try resolve(statement: statement)
        }
        return resolvedStatements
    }

    private mutating func resolve(statement: Statement<UnresolvedDepth>) throws -> Statement<Int> {
        switch statement {
        case .letDeclaration(let nameToken, let initializeExpr):
            return try handleLetDeclaration(nameToken: nameToken, initializeExpr: initializeExpr)
        case .expression(let expr):
            return try handleExpressionStatement(expr: expr)
        }
    }

    mutating private func handleLetDeclaration(nameToken: Token,
                                               initializeExpr: Expression<UnresolvedDepth>?) throws -> Statement<Int> {
        try declareVariable(variableToken: nameToken)

        var resolvedInitializerExpr: Expression<Int>? = nil
        if let initializeExpr {
            resolvedInitializerExpr = try resolve(expression: initializeExpr)
        }

        defineVariable(name: String(nameToken.lexeme))
        return .letDeclaration(nameToken, resolvedInitializerExpr)
    }

    mutating private func handleExpressionStatement(expr: Expression<UnresolvedDepth>) throws -> Statement<Int> {
        let resolvedExpression = try resolve(expression: expr)
        return .expression(resolvedExpression)
    }

    // Resolver for expressions
    mutating private func resolve(expression: Expression<UnresolvedDepth>) throws -> Expression<Int> {
        switch expression {
        case .variable(let nameToken, _):
            return try handleVariable(nameToken: nameToken)
        case .binary(let leftExpr, let operToken, let rightExpr):
            return try handleBinary(leftExpr: leftExpr, operToken: operToken, rightExpr: rightExpr)
        case .unary(let operToken, let rightExpr):
            return try handleUnary(operToken: operToken, rightExpr: rightExpr)
        case .literal(let valueToken, let value):
            return .literal(valueToken, value)
        case .list(let leftBracketToken, let elements):
            return try handleList(leftBracketToken: leftBracketToken, elements: elements)
        case .tuple(let leftParenToken, let expr0, let expr1, let expr2):
            return try handleTuple(leftParenToken: leftParenToken,
                                   expr0: expr0,
                                   expr1: expr1,
                                   expr2: expr2)
        case .constructor(let objectName, let leftParenToken, let arguments):
            return try handleConstructor(calleeExpr: objectName,
                                         leftParenToken: leftParenToken,
                                         arguments: arguments)
        }
    }

    mutating private func handleVariable(nameToken: Token) throws -> Expression<Int> {
        if !scopeStack.isEmpty && scopeStack.lastMutable[String(nameToken.lexeme)] == false {
            throw ResolverError.variableAccessedBeforeInitialization(nameToken)
        }

        let depth = try getDepth(nameToken: nameToken)
        return .variable(nameToken, depth)
    }

    mutating private func handleBinary(leftExpr: Expression<UnresolvedDepth>,
                                       operToken: Token,
                                       rightExpr: Expression<UnresolvedDepth>) throws -> Expression<Int> {
        let resolvedLeftExpr = try resolve(expression: leftExpr)
        let resolvedRightExpr = try resolve(expression: rightExpr)

        return .binary(resolvedLeftExpr, operToken, resolvedRightExpr)
    }

    mutating private func handleUnary(operToken: Token,
                                      rightExpr: Expression<UnresolvedDepth>) throws -> Expression<Int> {
        let resolvedRightExpr = try resolve(expression: rightExpr)

        return .unary(operToken, resolvedRightExpr)
    }

    mutating private func handleList(leftBracketToken: Token,
                                     elements: [Expression<UnresolvedDepth>]) throws -> Expression<Int> {
        let previousArgumentListType = currentArgumentListType
        currentArgumentListType = .listInitializer
        defer {
            currentArgumentListType = previousArgumentListType
        }

        let resolvedElements = try elements.map { element in
            return try resolve(expression: element)
        }

        return .list(leftBracketToken, resolvedElements)
    }

    mutating private func handleTuple(leftParenToken: Token,
                                      expr0: Expression<UnresolvedDepth>,
                                      expr1: Expression<UnresolvedDepth>,
                                      expr2: Expression<UnresolvedDepth>) throws -> Expression<Int> {
        let previousArgumentListType = currentArgumentListType
        currentArgumentListType = .tupleInitializer
        defer {
            currentArgumentListType = previousArgumentListType
        }

        let resolvedExpr0 = try resolve(expression: expr0)
        let resolvedExpr1 = try resolve(expression: expr1)
        let resolvedExpr2 = try resolve(expression: expr2)

        return .tuple(leftParenToken, resolvedExpr0, resolvedExpr1, resolvedExpr2)
    }

    mutating private func handleConstructor(calleeExpr: Expression<UnresolvedDepth>,
                                            leftParenToken: Token,
                                            arguments: [Expression<UnresolvedDepth>.Argument]) throws -> Expression<Int> {
        let previousArgumentListType = currentArgumentListType
        currentArgumentListType = .constructorCall
        defer {
            currentArgumentListType = previousArgumentListType
        }

        let resolvedCalleeExpr = try resolve(expression: calleeExpr)

        let resolvedArgs = try arguments.map { argument in
            let resolvedValue = try resolve(expression: argument.value)
            return Expression.Argument(name: argument.name, value: resolvedValue)
        }

        return .constructor(resolvedCalleeExpr, leftParenToken, resolvedArgs)
    }
}
