//
//  RuntimeError.swift
//  ScintillaApp
//
//  Created by Danielle Kefford on 1/26/25.
//

import Foundation

enum RuntimeError: LocalizedError, CustomStringConvertible {
    case undefinedVariable(Location, Substring)
    case undefinedFunction(Location, Substring)
    case undefinedMethod(Location, Substring)
    case unsupportedUnaryOperator(Location, Substring)
    case unaryOperandMustBeNumber(Location, Substring)
    case unsupportedBinaryOperator(Location, Substring)
    case binaryOperandsMustBeNumbers(Location, Substring)
    case notAFunction(Location, Substring)
    // TODO: Need to capture location and lexemes for the following three error cases
    case incorrectArgument
    case missingLastExpression
    case lastExpressionNeedsToBeWorld

    var description: String {
        switch self {
        case .undefinedVariable(let location, let name):
            return "[\(location)] Error: undefined variable, \(name)"
        case .undefinedFunction(let location, let name):
            return "[\(location)] Error: undefined function, \(name)"
        case .undefinedMethod(let location, let name):
            return "[\(location)] Error: undefined method, \(name)"
        case .unsupportedUnaryOperator(let location, let badOperator):
            return "[\(location)] Error: unsupported unary operator, \(badOperator)"
        case .unaryOperandMustBeNumber(let location, let badOperator):
            return "[\(location)] Error: unary operand must be number, \(badOperator)"
        case .unsupportedBinaryOperator(let location, let badOperator):
            return "[\(location)] Error: unsupported binary operator, \(badOperator)"
        case .binaryOperandsMustBeNumbers(let location, let badOperator):
            return "[\(location)] Error: binary operands must be numbers, \(badOperator)"
        case .notAFunction(let location, let badFunction):
            return "[\(location)] Error: not a function, \(badFunction)"
        case .incorrectArgument:
            return "[] Error: bad argument"
        case .missingLastExpression:
            return "[] Error: missing last expression"
        case .lastExpressionNeedsToBeWorld:
            return "[] Error: last expression needs to be world"
        }
    }
}
