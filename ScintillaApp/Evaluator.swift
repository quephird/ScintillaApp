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

    init() {
        let globalEnvironment = Environment()
        globalEnvironment.define(name: .variableName("PI"), value: .double(3.1415926))

        for builtin in ScintillaBuiltin.allCases {
            let name = builtin.objectName
            globalEnvironment.define(name: name, value: .builtin(builtin))
        }

        self.environment = globalEnvironment
    }

    private func prepareCode(source: String) throws -> Program<Int> {
        var tokenizer = Tokenizer(source: source)
        let tokens = try tokenizer.scanTokens()
        var parser = Parser(tokens: tokens)
        let program = try parser.parse()
        var resolver = Resolver()

        return try resolver.resolve(program: program)
    }

    func interpret(source: String) throws -> World {
        let program = try prepareCode(source: source)

        for statement in program.statements {
            try execute(statement: statement)
        }

        let finalExpr = try evaluate(expr: program.finalExpression)
        guard case .world(let world) = finalExpr else {
            throw RuntimeError.lastExpressionNeedsToBeWorld
        }

        return world
    }

    func execute(statement: Statement<Int>) throws {
        switch statement {
        case .letDeclaration(let nameToken, let expr):
            try handleLetDeclaration(nameToken: nameToken, expr: expr)
        case .functionDeclaration(let nameToken, let argumentNames, let letDecls, let returnExpr):
            try handleFunctionDeclaration(nameToken: nameToken,
                                          argumentNames: argumentNames,
                                          letDecls: letDecls,
                                          returnExpr: returnExpr)
        case .expression(let expr):
            let _ = try evaluate(expr: expr)
        }
    }

    private func handleLetDeclaration(nameToken: Token, expr: Expression<Int>) throws {
        let value = try evaluate(expr: expr)

        let name: ObjectName = .variableName(nameToken.lexeme)
        environment.define(name: name, value: value)
    }

    private func handleFunctionDeclaration(nameToken: Token,
                                           argumentNames: [Token],
                                           letDecls: [Statement<Int>],
                                           returnExpr: Expression<Int>) throws {
        let environmentWhenDeclared = self.environment
        let function = UserDefinedFunction(name: String(nameToken.lexeme),
                                           argumentNames: argumentNames,
                                           enclosingEnvironment: environmentWhenDeclared,
                                           letDecls: letDecls,
                                           returnExpr: returnExpr)
        let argumentNames = argumentNames.map { $0.lexeme }
        let name: ObjectName = .functionName(nameToken.lexeme, argumentNames)
        environment.define(name: name, value: .userDefinedFunction(function))
    }

    public func evaluate(expr: Expression<Int>) throws -> ScintillaValue {
        switch expr {
        case .literal(_, let literal):
            return literal
        case .unary(let oper, let expr):
            return try handleUnaryExpression(oper: oper, expr: expr)
        case .binary(let leftExpr, let oper, let rightExpr):
            return try handleBinaryExpression(leftExpr: leftExpr, oper: oper, rightExpr: rightExpr)
        case .variable(let varToken, let depth):
            return try handleVariableExpression(varToken: varToken, depth: depth)
        case .list(_, let elements):
            return try handleListExpression(elements: elements)
        case .tuple2(_, let expr0, let expr1):
            return try handleTuple2Expression(expr0: expr0,
                                              expr1: expr1)
        case .tuple3(_, let expr0, let expr1, let expr2):
            return try handleTuple3Expression(expr0: expr0,
                                              expr1: expr1,
                                              expr2: expr2)
        case .function(let calleeName, let argumentNames, let depth):
            return try handleFunction(calleeToken: calleeName,
                                      argumentNameTokens: argumentNames,
                                      depth: depth)
        case .lambda(_, let argumentNames, let expression):
            return try handleLambda(argumentNames: argumentNames,
                                    expression: expression)
        case .method(let calleeExpr, let methodToken, let argumentNameTokens):
            return try handleMethod(calleeExpr: calleeExpr,
                                    methodToken: methodToken,
                                    argumentNameTokens: argumentNameTokens)
        case .call(let calleeExpr, _, let arguments):
            return try handleCall(calleeExpr: calleeExpr,
                                  arguments: arguments)
        }
    }

    private func handleUnaryExpression(oper: Token, expr: Expression<Int>) throws -> ScintillaValue {
        let value = try evaluate(expr: expr)

        switch oper.type {
        case .minus:
            switch value {
            case .double(let number):
                return .double(-number)
            default:
                throw RuntimeError.unaryOperandMustBeNumber(oper.location, oper.lexeme)
            }
        default:
            throw RuntimeError.unsupportedUnaryOperator(oper.location, oper.lexeme)
        }
    }

    private func handleBinaryExpression(leftExpr: Expression<Int>,
                                        oper: Token,
                                        rightExpr: Expression<Int>) throws -> ScintillaValue {
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
            default:
                throw RuntimeError.unsupportedBinaryOperator(oper.location, oper.lexeme)
            }
        default:
            throw RuntimeError.binaryOperandsMustBeNumbers(oper.location, oper.lexeme)
        }
    }

    private func handleVariableExpression(varToken: Token, depth: Int) throws -> ScintillaValue {
        let name: ObjectName = .variableName(varToken.lexeme)
        return try environment.getValueAtDepth(name: name, depth: depth)
    }

    private func handleListExpression(elements: [Expression<Int>]) throws -> ScintillaValue {
        let elementValues = try elements.map{ try evaluate(expr: $0) }

        return .list(elementValues)
    }

    private func handleTuple2Expression(expr0: Expression<Int>,
                                        expr1: Expression<Int>) throws -> ScintillaValue {
        let value0 = try evaluate(expr: expr0)
        let value1 = try evaluate(expr: expr1)

        return .tuple2((value0, value1))
    }

    private func handleTuple3Expression(expr0: Expression<Int>,
                                        expr1: Expression<Int>,
                                        expr2: Expression<Int>) throws -> ScintillaValue {
        let value0 = try evaluate(expr: expr0)
        let value1 = try evaluate(expr: expr1)
        let value2 = try evaluate(expr: expr2)

        return .tuple3((value0, value1, value2))
    }

    private func handleFunction(calleeToken: Token,
                                argumentNameTokens: [Token?],
                                depth: Int) throws -> ScintillaValue {
        let baseName = calleeToken.lexeme
        let argumentNames = argumentNameTokens.map { maybeNameToken in
            if let nameToken = maybeNameToken  {
                return nameToken.lexeme
            }

            return ""
        }
        let calleeName: ObjectName = .functionName(baseName, argumentNames)
        let callee = try environment.getValueAtDepth(name: calleeName, depth: depth)

        guard callee.isCallable else {
            throw RuntimeError.notAFunction(calleeToken.location, calleeToken.lexeme)
        }

        return callee
    }

    private func handleCall(calleeExpr: Expression<Int>,
                            arguments: [Expression<Int>.Argument]) throws -> ScintillaValue {
        let callee = try evaluate(expr: calleeExpr)
        let argumentValues = try arguments.map { try evaluate(expr: $0.value) }

        if case .builtin(let builtin) = callee {
            // TODO: Need to package up arguments such that names, locations, _and_ values
            // are all accessible within the call() function.
            return try builtin.call(evaluator: self, argumentValues: argumentValues)
        }

        if case .boundMethod(let callee, let builtin) = callee {
            return try builtin.callMethod(object: callee, argumentValues: argumentValues)
        }

        if case .userDefinedFunction(let userDefinedFunction) = callee {
            return try userDefinedFunction.call(evaluator: self, argumentValues: argumentValues)
        }

        throw RuntimeError.notCallable(calleeExpr.locationToken.location, calleeExpr.locationToken.lexeme)
    }

    private func reuseOrCreateEnvironment(environment: Environment) -> Environment {
        var cursor: Environment? = self.environment
        while cursor != nil {
            if cursor === environment {
                return Environment(enclosingEnvironment: environment.enclosingEnvironment)
            }
            cursor = cursor!.enclosingEnvironment
        }

        // Can reuse `environment`
        environment.undefineAll()
        return environment
    }

    private func handleLambda(argumentNames: [Token],
                              expression: Expression<Int>) throws -> ScintillaValue {
        let udf = UserDefinedFunction(name: "",
                                      argumentNames: argumentNames,
                                      enclosingEnvironment: self.environment,
                                      letDecls: [],
                                      returnExpr: expression)

        return .implicitSurfaceLambda(udf)
    }

    private func handleMethod(calleeExpr: Expression<Int>,
                              methodToken: Token,
                              argumentNameTokens: [Token?]) throws -> ScintillaValue {
        let callee = try evaluate(expr: calleeExpr)
        let methodName = methodToken.lexeme
        let argumentNames = try argumentNameTokens.map { maybeNameToken in
            guard let nameToken = maybeNameToken else {
                throw RuntimeError.missingArgumentName(methodToken)
            }
            return nameToken.lexeme
        }
        let methodObjectName: ObjectName = .methodName(callee.type, methodName, argumentNames)

        let methodValue = try environment.getValue(name: methodObjectName)
        guard case .builtin(let builtin) = methodValue else {
            throw RuntimeError.notAFunction(methodToken.location, methodToken.lexeme)
        }

        return .boundMethod(callee, builtin)
    }
}
