//
//  Resolver.swift
//  ScintillaApp
//
//  Created by Danielle Kefford on 1/25/25.
//

struct Resolver {
    // TODO: Check if we need all of these
    private enum FunctionType {
        case none
        case function
        case method
        case lambda
        case initializer
    }

    private enum ArgumentListType {
        case none
        case constructorCall
        case methodCall
        case listInitializer
        case tupleInitializer
    }

    private var scopeStack: [[ObjectName: Bool]]
    private var currentFunctionType: FunctionType = .none
    private var currentArgumentListType: ArgumentListType = .none

    init() {
        var builtins = ScintillaBuiltin.allCases.map{ builtin in
            (builtin.objectName, true)
        }
        builtins.append((.variableName("PI"), true))

        self.scopeStack = [Dictionary(uniqueKeysWithValues: builtins)]
    }
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
        let name: ObjectName = .variableName(variableToken.lexeme)
        try declareObject(objectName: name)
    }

    mutating private func defineVariable(variableToken: Token) {
        let name: ObjectName = .variableName(variableToken.lexeme)
        defineObject(objectName: name)
    }

    mutating private func declareFunction(nameToken: Token, argumentNameTokens: [Token]) throws {
        let argumentNames = argumentNameTokens.map { $0.lexeme }
        let name: ObjectName = .functionName(nameToken.lexeme, argumentNames)
        try declareObject(objectName: name)
    }

    mutating private func defineFunction(nameToken: Token, argumentNameTokens: [Token]) {
        let argumentNames = argumentNameTokens.map { $0.lexeme }
        let name: ObjectName = .functionName(nameToken.lexeme, argumentNames)
        defineObject(objectName: name)
    }

    mutating private func declareObject(objectName: ObjectName) throws {
        // ACHTUNG!!! Only variables declared/defined in local
        // blocks are tracked by the resolver, which is why
        // we bail here since the stack is empty in the
        // global environment.
        if scopeStack.isEmpty {
            return
        }

        if scopeStack.lastMutable.keys.contains(objectName) {
            throw ResolverError.variableAlreadyDefined(objectName)
        }

        scopeStack.lastMutable[objectName] = false
    }

    mutating private func defineObject(objectName: ObjectName) {
        // ACHTUNG!!! Only variables declared/defined in local
        // blocks are tracked by the resolver, which is why
        // we bail here since the stack is empty in the
        // global environment.
        if scopeStack.isEmpty {
            return
        }

        scopeStack.lastMutable[objectName] = true
    }

    private func getDepth(name: ObjectName, nameToken: Token) throws -> Int {
        var i = scopeStack.count - 1
        while i >= 0 {
            if let _ = scopeStack[i][name] {
                return scopeStack.count - 1 - i
            }

            i = i - 1
        }

        switch name {
        case .variableName:
            throw ResolverError.undefinedVariable(nameToken)
        case .functionName(let inboundBaseName, _):
            for scope in scopeStack {
                if scope.keys.contains(where: {
                    if case .functionName(let baseName, _) = $0, baseName == inboundBaseName {
                        return true
                    }
                    return false
                }) {
                    throw ResolverError.incorrectArgumentsForFunction(nameToken)
                }
            }

            throw ResolverError.undefinedFunction(nameToken)
        case .methodName:
            fatalError("Methods should not need to be resolved")
        }
    }
}

extension Resolver {
    // Main point of entry
    mutating func resolve(program: Program<UnresolvedDepth>) throws -> Program<Int> {
        let resolvedStatements = try program.statements.map { statement in
            return try resolve(statement: statement)
        }

        let resolvedFinalExpression = try resolve(expression: program.finalExpression)

        return Program(statements: resolvedStatements, finalExpression: resolvedFinalExpression)
    }

    private mutating func resolve(statement: Statement<UnresolvedDepth>) throws -> Statement<Int> {
        switch statement {
        case .letDeclaration(let nameToken, let initializeExpr):
            return try handleLetDeclaration(nameToken: nameToken, initializeExpr: initializeExpr)
        case .functionDeclaration(let nameToken, let argumentNames, let letDecls, let returnExpr):
            return try handleFunctionDeclaration(nameToken: nameToken,
                                                 argumentNames: argumentNames,
                                                 letDecls: letDecls,
                                                 returnExpr: returnExpr)
        case .expression(let expr):
            return try handleExpressionStatement(expr: expr)
        }
    }

    mutating private func handleLetDeclaration(nameToken: Token,
                                               initializeExpr: Expression<UnresolvedDepth>) throws -> Statement<Int> {
        try declareVariable(variableToken: nameToken)

        let resolvedInitializerExpr = try resolve(expression: initializeExpr)

        defineVariable(variableToken: nameToken)
        return .letDeclaration(nameToken, resolvedInitializerExpr)
    }

    mutating private func handleFunctionDeclaration(nameToken: Token,
                                                    argumentNames: [Token],
                                                    letDecls: [Statement<UnresolvedDepth>],
                                                    returnExpr: Expression<UnresolvedDepth>) throws -> Statement<Int> {
        try declareFunction(nameToken: nameToken, argumentNameTokens: argumentNames)
        defineFunction(nameToken: nameToken, argumentNameTokens: argumentNames)

        beginScope()
        let previousFunctionType = currentFunctionType
        currentFunctionType = .function
        defer {
            endScope()
            currentFunctionType = previousFunctionType
        }

        for argumentName in argumentNames {
            try declareVariable(variableToken: argumentName)
            defineVariable(variableToken: argumentName)
        }

        let resolvedLetDecls = try letDecls.map { try resolve(statement: $0) }
        let resolvedReturnExpr = try resolve(expression: returnExpr)

        return .functionDeclaration(nameToken, argumentNames, resolvedLetDecls, resolvedReturnExpr)
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
        case .tuple2(let leftParenToken, let expr0, let expr1):
            return try handleTuple2(leftParenToken: leftParenToken,
                                    expr0: expr0,
                                    expr1: expr1)
        case .tuple3(let leftParenToken, let expr0, let expr1, let expr2):
            return try handleTuple3(leftParenToken: leftParenToken,
                                    expr0: expr0,
                                    expr1: expr1,
                                    expr2: expr2)
        case .constructor(let calleeName, let argumentNames, _):
            return try handleConstructor(calleeToken: calleeName,
                                         argumentNameTokens: argumentNames)
        case .lambda(let leftBraceToken, let argumentNames, let expression):
            return try handleLambda(leftBraceToken: leftBraceToken,
                                    argumentNames: argumentNames,
                                    expression: expression)
        case .method(let calleeExpr, let methodName, let argumentNameTokens):
            return try handleMethod(calleeExpr: calleeExpr,
                                    methodName: methodName,
                                    argumentNameTokens: argumentNameTokens)
        case .call(let calleeExpr, let leftParenToken, let arguments):
            return try handleCall(calleeExpr: calleeExpr,
                                  leftParenToken: leftParenToken,
                                  arguments: arguments)
        }
    }

    mutating private func handleVariable(nameToken: Token) throws -> Expression<Int> {
        let name: ObjectName = .variableName(nameToken.lexeme)
        if !scopeStack.isEmpty && scopeStack.lastMutable[name] == false {
            throw ResolverError.variableAccessedBeforeInitialization(nameToken)
        }

        let depth = try getDepth(name: name, nameToken: nameToken)
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

    mutating private func handleTuple2(leftParenToken: Token,
                                       expr0: Expression<UnresolvedDepth>,
                                       expr1: Expression<UnresolvedDepth>) throws -> Expression<Int> {
        let previousArgumentListType = currentArgumentListType
        currentArgumentListType = .tupleInitializer
        defer {
            currentArgumentListType = previousArgumentListType
        }

        let resolvedExpr0 = try resolve(expression: expr0)
        let resolvedExpr1 = try resolve(expression: expr1)

        return .tuple2(leftParenToken, resolvedExpr0, resolvedExpr1)
    }

    mutating private func handleTuple3(leftParenToken: Token,
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

        return .tuple3(leftParenToken, resolvedExpr0, resolvedExpr1, resolvedExpr2)
    }

    mutating private func handleConstructor(calleeToken: Token,
                                            argumentNameTokens: [Token?]) throws -> Expression<Int> {
        let previousArgumentListType = currentArgumentListType
        currentArgumentListType = .constructorCall
        defer {
            currentArgumentListType = previousArgumentListType
        }

        let baseName = calleeToken.lexeme
        let argumentNames = argumentNameTokens.map { maybeNameToken in
            if let nameToken = maybeNameToken {
                return nameToken.lexeme
            }

            return ""
        }
        let name: ObjectName = .functionName(baseName, argumentNames)
        let depth = try getDepth(name: name, nameToken: calleeToken)

        return .constructor(calleeToken, argumentNameTokens, depth)
    }

    mutating private func handleCall(calleeExpr: Expression<UnresolvedDepth>,
                                     leftParenToken: Token,
                                     arguments: [Expression<UnresolvedDepth>.Argument]) throws -> Expression<Int> {
        let previousArgumentListType = currentArgumentListType
        currentArgumentListType = .constructorCall
        defer {
            currentArgumentListType = previousArgumentListType
        }

        var newCalleeExpr = calleeExpr
        let argumentNames = arguments.map { $0.name }
        if case .variable(let baseNameToken, _) = calleeExpr {
            newCalleeExpr = .constructor(baseNameToken, argumentNames, UnresolvedDepth())
        } else if case .method(let innerCalleeExpr, let baseNameToken, _) = calleeExpr {
            newCalleeExpr = .method(innerCalleeExpr, baseNameToken, argumentNames)
        }

        let resolvedCalleeExpr = try resolve(expression: newCalleeExpr)

        let resolvedArguments = try arguments.map { argument in
            let resolvedValue = try resolve(expression: argument.value)
            return Expression.Argument(name: argument.name, value: resolvedValue)
        }

        return .call(resolvedCalleeExpr, leftParenToken, resolvedArguments)
    }

    mutating private func handleLambda(leftBraceToken: Token,
                                       argumentNames: [Token],
                                       expression: Expression<UnresolvedDepth>) throws -> Expression<Int> {
        beginScope()
        let previousFunctionType = currentFunctionType
        currentFunctionType = .lambda
        defer {
            endScope()
            currentFunctionType = previousFunctionType
        }

        for argumentName in argumentNames {
            try declareVariable(variableToken: argumentName)
            defineVariable(variableToken: argumentName)
        }

        let resolvedExpr = try resolve(expression: expression)

        return .lambda(leftBraceToken, argumentNames, resolvedExpr)
    }

    mutating private func handleMethod(calleeExpr: Expression<UnresolvedDepth>,
                                       methodName: Token,
                                       argumentNameTokens: [Token?]) throws -> Expression<Int> {
        let resolvedCalleeExpr = try resolve(expression: calleeExpr)

        return .method(resolvedCalleeExpr, methodName, argumentNameTokens)
    }
}
