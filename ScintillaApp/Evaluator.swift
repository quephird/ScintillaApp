//
//  Evaluator.swift
//  ScintillaApp
//
//  Created by Danielle Kefford on 1/26/25.
//

import Foundation

import ScintillaLib

class Evaluator {
    var environment: Environment
    var allEnvironments: [Environment] = []

    init() {
        let globalEnvironment = Environment()

        for builtin in ScintillaBuiltin.allCases {
            let name = builtin.objectName
            globalEnvironment.define(name: name, value: .builtin(builtin))
        }

        globalEnvironment.define(name: .variableName("pi"), value: .double(PI))

        self.environment = globalEnvironment
    }

    public func recycleEnvironment(enclosingEnvironment: Environment) -> Environment {
        for index in self.allEnvironments.indices.reversed() {
            if isKnownUniquelyReferenced(&self.allEnvironments[index]) {
                let recycledEnvironment = self.allEnvironments[index]
                recycledEnvironment.enclosingEnvironment = enclosingEnvironment
                recycledEnvironment.undefineAll()

                return recycledEnvironment
            }
        }

        let newEnvironment = Environment(enclosingEnvironment: enclosingEnvironment)
        self.allEnvironments.append(newEnvironment)

        return newEnvironment
    }

    private func prepareCode(source: String) throws -> Program<ResolvedLocation> {
        var tokenizer = Tokenizer(source: source)
        let tokens = try tokenizer.scanTokens()
        var parser = Parser(tokens: tokens)
        let program = try parser.parse()
        var resolver = Resolver()

        return try resolver.resolve(program: program)
    }

    func interpret(source: String) throws -> World {
        let finalExpr = try interpretRaw(source: source)

        guard case .world(let world) = finalExpr else {
            throw RuntimeError.lastExpressionNeedsToBeWorld
        }

        return world
    }

    func interpretRaw(source: String) throws -> ScintillaValue {
        let program = try prepareCode(source: source)

        for statement in program.statements {
            try execute(statement: statement)
        }

        return try evaluate(expr: program.finalExpression)
    }

    func execute(statement: Statement<ResolvedLocation>) throws {
        switch statement {
        case .letDeclaration(let lhsPattern, let equalsToken, let rhsExpr):
            try handleLetDeclaration(lhsPattern: lhsPattern,
                                     equalsToken: equalsToken,
                                     rhsExpr: rhsExpr)
        case .functionDeclaration(let nameToken, let parameters, let letDecls, let returnExpr):
            try handleFunctionDeclaration(nameToken: nameToken,
                                          parameters: parameters,
                                          letDecls: letDecls,
                                          returnExpr: returnExpr)
        case .expression(let expr):
            let _ = try evaluate(expr: expr)
        }
    }

    private func handleLetDeclaration(lhsPattern: AssignmentPattern,
                                      equalsToken: Token,
                                      rhsExpr: Expression<ResolvedLocation>) throws {
        let value = try evaluate(expr: rhsExpr)

        try handlePattern(pattern: lhsPattern, value: value, environment: self.environment)
    }

    public func handlePattern(pattern: AssignmentPattern,
                              value: ScintillaValue,
                              environment: Environment) throws {
        switch pattern {
        case .wildcard:
            break
        case .variable(let nameToken):
            let name: ObjectName = .variableName(nameToken.lexeme)
            environment.define(name: name, value: value)
        case .tuple2(let pattern1, let pattern2):
            guard case .tuple2((let value1, let value2)) = value else {
                throw RuntimeError.expectedTuplePattern(2)
            }

            for (pattern, value) in [(pattern1, value1),
                                     (pattern2, value2)] {
                try handlePattern(pattern: pattern, value: value, environment: environment)
            }
        case .tuple3(let pattern1, let pattern2, let pattern3):
            guard case .tuple3((let value1, let value2, let value3)) = value else {
                throw RuntimeError.expectedTuplePattern(3)
            }

            for (pattern, value) in [(pattern1, value1),
                                     (pattern2, value2),
                                     (pattern3, value3)] {
                try handlePattern(pattern: pattern, value: value, environment: environment)
            }
        }
    }

    private func handleFunctionDeclaration(nameToken: Token,
                                           parameters: [Parameter],
                                           letDecls: [Statement<ResolvedLocation>],
                                           returnExpr: Expression<ResolvedLocation>) throws {
        let environmentWhenDeclared = self.environment
        let function = UserDefinedFunction(name: String(nameToken.lexeme),
                                           parameters: parameters,
                                           enclosingEnvironment: environmentWhenDeclared,
                                           letDecls: letDecls,
                                           returnExpr: returnExpr)

        let parameterNames = try parameters.map { parameter in
            guard let parameterName = parameter.name else {
                throw RuntimeError.missingParameterName(nameToken)
            }

            return parameterName.lexeme
        }

        let name: ObjectName = .functionName(nameToken.lexeme, parameterNames)
        environment.define(name: name, value: .userDefinedFunction(function))
    }

    public func evaluate(expr: Expression<ResolvedLocation>) throws -> ScintillaValue {
        switch expr {
        case .boolLiteral(_, let value):
            return .boolean(value)
        case .variable(let varToken, let location):
            return try handleVariableExpression(varToken: varToken, location: location)
        case .list(_, let elements):
            return try handleListExpression(elements: elements)
        case .tuple2(_, let expr0, let expr1):
            return try handleTuple2Expression(expr0: expr0,
                                              expr1: expr1)
        case .tuple3(_, let expr0, let expr1, let expr2):
            return try handleTuple3Expression(expr0: expr0,
                                              expr1: expr1,
                                              expr2: expr2)
        case .function(let calleeName, let argumentNames, let location):
            return try handleFunction(calleeToken: calleeName,
                                      argumentNameTokens: argumentNames,
                                      location: location)
        case .lambda(_, let parameters, let letDecls, let expression):
            return try handleLambda(parameters: parameters,
                                    letDecls: letDecls,
                                    expression: expression)
        case .method(let calleeExpr, let methodToken, let argumentNameTokens):
            return try handleMethod(calleeExpr: calleeExpr,
                                    methodToken: methodToken,
                                    argumentNameTokens: argumentNameTokens)
        case .call(let calleeExpr, _, let arguments):
            return try handleCall(calleeExpr: calleeExpr,
                                  arguments: arguments)
        case .binary(let leftExpr, let oper, let rightExpr):
            return try handleBinaryExpression(leftExpr: leftExpr, oper: oper, rightExpr: rightExpr)
        case .doubleLiteral, .unary:
            let result = try evaluateDouble(expr: expr)
            return .double(result)
        }
    }

    public func evaluateDouble(expr: Expression<ResolvedLocation>) throws -> Double {
        switch expr {
        case .doubleLiteral(_, let value):
            return value
        case .unary(let oper, let expr):
            return try handleUnaryExpression(oper: oper, expr: expr)
        case .call(let calleeExpr, _, let arguments):
            return try handleCallDouble(calleeExpr: calleeExpr, arguments: arguments)
        case .variable(let name, let location):
            return try handleVariableExpressionDouble(varToken: name, location: location)
        default:
            let result = try evaluate(expr: expr)

            guard case .double(let double) = result else {
                throw RuntimeError.expectedDouble
            }

            return double
        }
    }

    private func handleUnaryExpression(oper: Token, expr: Expression<ResolvedLocation>) throws -> Double {
        let number = try evaluateDouble(expr: expr)

        switch oper.type {
        case .minus:
            return -number
        default:
            throw RuntimeError.unsupportedUnaryOperator(oper.location, oper.lexeme)
        }
    }

    private func handleBinaryExpression(leftExpr: Expression<ResolvedLocation>,
                                        oper: Token,
                                        rightExpr: Expression<ResolvedLocation>) throws -> ScintillaValue {
        let leftValue = try evaluate(expr: leftExpr)
        let rightValue = try evaluate(expr: rightExpr)

        switch (leftValue, rightValue) {
        case (.double(let leftNumber), .double(let rightNumber)):
            switch oper.type {
            case .plus:
                return .double(leftNumber + rightNumber)
            case .minus:
                return .double(leftNumber - rightNumber)
            case .star:
                return .double(leftNumber * rightNumber)
            case .slash:
                return .double(leftNumber / rightNumber)
            case .caret:
                return .double(pow(leftNumber, rightNumber))
            default:
                throw RuntimeError.unsupportedBinaryOperator(oper.location, oper.lexeme)
            }
        case (.list(let leftList), .list(let rightList)):
            switch oper.type {
            case .plus:
                return .list(leftList + rightList)
            default:
                throw RuntimeError.unsupportedBinaryOperator(oper.location, oper.lexeme)
            }
        default:
            throw RuntimeError.binaryOperandsMustBeNumbersOrLists(oper.location, oper.lexeme)
        }
    }

    private func handleVariableExpression(varToken: Token, location: ResolvedLocation) throws -> ScintillaValue {
        return try environment.getValueAtLocation(location: location)
    }

    private func handleVariableExpressionDouble(varToken: Token, location: ResolvedLocation) throws -> Double {
        let result = try environment.getValueAtLocation(location: location)
        guard case .double(let double) = result else {
            throw RuntimeError.expectedDouble
        }
        return double
    }

    private func handleListExpression(elements: [Expression<ResolvedLocation>]) throws -> ScintillaValue {
        let elementValues = try elements.map{ try evaluate(expr: $0) }

        return .list(elementValues)
    }

    private func handleTuple2Expression(expr0: Expression<ResolvedLocation>,
                                        expr1: Expression<ResolvedLocation>) throws -> ScintillaValue {
        let value0 = try evaluate(expr: expr0)
        let value1 = try evaluate(expr: expr1)

        return .tuple2((value0, value1))
    }

    private func handleTuple3Expression(expr0: Expression<ResolvedLocation>,
                                        expr1: Expression<ResolvedLocation>,
                                        expr2: Expression<ResolvedLocation>) throws -> ScintillaValue {
        let value0 = try evaluate(expr: expr0)
        let value1 = try evaluate(expr: expr1)
        let value2 = try evaluate(expr: expr2)

        return .tuple3((value0, value1, value2))
    }

    private func handleFunction(calleeToken: Token,
                                argumentNameTokens: [Token?],
                                location: ResolvedLocation) throws -> ScintillaValue {
        let callee = try environment.getValueAtLocation(location: location)

        guard callee.isCallable else {
            throw RuntimeError.notAFunction(calleeToken.location, calleeToken.lexeme)
        }

        return callee
    }

    private func handleCall(calleeExpr: Expression<ResolvedLocation>,
                            arguments: [Expression<ResolvedLocation>.Argument]) throws -> ScintillaValue {
        let callee = try evaluate(expr: calleeExpr)
        let argumentValues = try arguments.map { try evaluate(expr: $0.value) }

        if case .builtin(let builtin) = callee {
            // TODO: Need to package up arguments such that names, locations, _and_ values
            // are all accessible within the call() function.
            return try builtin.call(evaluator: self, argumentValues: argumentValues)
        }

        if case .boundMethod(let callee, let builtin) = callee {
            return try builtin.callMethod(evaluator: self,
                                          object: callee,
                                          argumentValues: argumentValues)
        }

        if case .userDefinedFunction(let userDefinedFunction) = callee {
            return try userDefinedFunction.call(evaluator: self, argumentValues: argumentValues)
        }

        throw RuntimeError.notCallable(calleeExpr.locationToken.location, calleeExpr.locationToken.lexeme)
    }

    private func handleCallDouble(calleeExpr: Expression<ResolvedLocation>,
                                  arguments: [Expression<ResolvedLocation>.Argument]) throws -> Double {
        let callee = try evaluate(expr: calleeExpr)

        switch callee {
        case .builtin(.sinFunc):
            let arg = try evaluateDouble(expr: arguments[0].value)
            return sin(arg)
        case .builtin(.cosFunc):
            let arg = try evaluateDouble(expr: arguments[0].value)
            return cos(arg)
        case .builtin(.tanFunc):
            let arg = try evaluateDouble(expr: arguments[0].value)
            return tan(arg)
        case .userDefinedFunction(let udf) where arguments.count <= 3:
            func extract(at i: Int) throws -> Double {
                guard i < arguments.count else { return 0.0 }
                return try evaluateDouble(expr: arguments[i].value)
            }

            let a1 = try extract(at: 0)
            let a2 = try extract(at: 1)
            let a3 = try extract(at: 2)

            return try udf.call(evaluator: self, argumentValues: a1, a2, a3)
        default:
            let result = try handleCall(calleeExpr: calleeExpr,
                                        arguments: arguments)
            guard case .double(let doubleValue) = result else {
                throw RuntimeError.expectedDouble
            }

            return doubleValue
        }
    }

    private func handleLambda(parameters: [Parameter],
                              letDecls: [Statement<ResolvedLocation>],
                              expression: Expression<ResolvedLocation>) throws -> ScintillaValue {
        let udf = UserDefinedFunction(name: "",
                                      parameters: parameters,
                                      enclosingEnvironment: self.environment,
                                      letDecls: letDecls,
                                      returnExpr: expression)

        return .lambda(udf)
    }

    private func handleMethod(calleeExpr: Expression<ResolvedLocation>,
                              methodToken: Token,
                              argumentNameTokens: [Token?]) throws -> ScintillaValue {
        let callee = try evaluate(expr: calleeExpr)
        let methodName = methodToken.lexeme
        let argumentNames = argumentNameTokens.map { nameToken in
            if let nameToken {
                return nameToken.lexeme
            }

            return ""
        }
        let methodObjectName: ObjectName = .methodName(callee.type, methodName, argumentNames)

        let methodValue = try environment.getValue(name: methodObjectName)
        guard case .builtin(let builtin) = methodValue else {
            throw RuntimeError.notAFunction(methodToken.location, methodToken.lexeme)
        }

        return .boundMethod(callee, builtin)
    }
}
