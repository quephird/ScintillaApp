//
//  Evaluator.swift
//  ScintillaApp
//
//  Created by Danielle Kefford on 1/26/25.
//

import Foundation

class Evaluator {
    var environment: Environment

    init() {
        let globalEnvironment = Environment()
        globalEnvironment.define(name: .variableName("PI"), value: .double(3.1415926))

        for builtin in ScintillaBuiltin.allCases {
            let name = builtin.objectName
            globalEnvironment.define(name: name, value: .function(builtin))
        }

        self.environment = globalEnvironment
    }

    private func prepareCode(source: String) throws -> [Statement<Int>] {
        var tokenizer = Tokenizer(source: source)
        let tokens = try tokenizer.scanTokens()
        var parser = Parser(tokens: tokens)
        let statements = try parser.parse()
        var resolver = Resolver()

        return try resolver.resolve(statements: statements)
    }

    func interpret(source: String) throws {
        let statements = try prepareCode(source: source)

        for statement in statements {
            try execute(statement: statement)
        }
    }

    func execute(statement: Statement<Int>) throws {
        switch statement {
        case .letDeclaration(let nameToken, let expr):
            try handleLetDeclaration(nameToken: nameToken, expr: expr)
        case .expression(let expr):
            let _ = try evaluate(expr: expr)
        }
    }

    private func handleLetDeclaration(nameToken: Token, expr: Expression<Int>) throws {
        let value = try evaluate(expr: expr)

        let name: ObjectName = .variableName(nameToken.lexeme)
        environment.define(name: name, value: value)
    }

    private func evaluate(expr: Expression<Int>) throws -> ScintillaValue {
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
        case .tuple(_, let expr0, let expr1, let expr2):
            return try handleTupleExpression(expr0: expr0,
                                             expr1: expr1,
                                             expr2: expr2)
        case .function(let calleeName, let arguments, _):
            return try handleFunction(calleeToken: calleeName,
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

    private func handleTupleExpression(expr0: Expression<Int>,
                                       expr1: Expression<Int>,
                                       expr2: Expression<Int>) throws -> ScintillaValue {
        let value0 = try evaluate(expr: expr0)
        let value1 = try evaluate(expr: expr1)
        let value2 = try evaluate(expr: expr2)

        return .tuple((value0, value1, value2))
    }

    private func handleFunction(calleeToken: Token,
                                arguments: [Expression<Int>.Argument]) throws -> ScintillaValue {
        let argumentValues = try arguments.map { try evaluate(expr: $0.value) }

        let baseName = calleeToken.lexeme
        let argumentNames = arguments.map { $0.name.lexeme }
        let calleeName: ObjectName = .functionName(baseName, argumentNames)
        let callee = try environment.getValue(name: calleeName)

        guard case .function(let callee) = callee else {
            throw RuntimeError.notAFunction(calleeToken.location, calleeToken.lexeme)
        }

        // TODO: Need to package up arguments such that names, locations, _and_ values
        // are all accessible within the call() function.
        return try callee.call(argumentValues: argumentValues)
    }
}
