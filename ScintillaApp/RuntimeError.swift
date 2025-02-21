//
//  RuntimeError.swift
//  ScintillaApp
//
//  Created by Danielle Kefford on 1/26/25.
//

import Foundation

enum RuntimeError: LocalizedError, CustomStringConvertible, Equatable {
    case undefinedVariable(SourceLocation, Substring)
    case undefinedFunction(SourceLocation, Substring)
    case undefinedMethod(SourceLocation, Substring)
    case unsupportedUnaryOperator(SourceLocation, Substring)
    case unaryOperandMustBeNumber(SourceLocation, Substring)
    case unsupportedBinaryOperator(SourceLocation, Substring)
    case binaryOperandsMustBeNumbers(SourceLocation, Substring)
    case notAFunction(SourceLocation, Substring)
    case notCallable(SourceLocation, Substring)
    // TODO: Need to capture location and lexemes for the following three error cases
    case missingArgumentName(Token)
    case incorrectArgument
    case incorrectObject
    case expectedBoolean
    case expectedDouble
    case expectedTuple
    case expectedLambda
    case expectedCamera
    case expectedLight
    case expectedShape
    case expectedUserDefinedFunction
    case implicitSurfaceLambdaWrongArity
    case parametricSurfaceLambdaWrongArity
    case missingLastExpression
    case lastExpressionNeedsToBeWorld
    case couldNotEvaluateVariable(Token)
    case couldNotEvaluateFunction(Token)
    case couldNotConstructLambda(Token)
    case notAPureMathFunction(ObjectName)

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
        case .notCallable(let location, let badObject):
            return "[\(location)] Error: not a function, \(badObject)"
        case .missingArgumentName(let token):
            return "[\(token.location)] Error: missing argument for method, \(token.lexeme)"
        case .incorrectArgument:
            return "[] Error: bad argument"
        case .expectedBoolean:
            return "[] Error: expected a boolean value for the argument"
        case .expectedDouble:
            return "[] Error: expected a double value for the argument"
        case .expectedTuple:
            return "[] Error: expected a tuple for the argument"
        case .expectedLambda:
            return "[] Error: expected a lambda for the argument"
        case .expectedCamera:
            return "[] Error: expected a camera for the argument"
        case .expectedLight:
            return "[] Error: expected the argument to be a list of Lights"
        case .expectedShape:
            return "[] Error: expected the argument to be a list of Shapes"
        case .incorrectObject:
            return "[] Error: method does not exist on object"
        case .expectedUserDefinedFunction:
            return "[] Error: expected user-defined function"
        case .implicitSurfaceLambdaWrongArity:
            return "[] Error: implicit surface lambda must take three arguments"
        case .parametricSurfaceLambdaWrongArity:
            return "[] Error: parametric surface lambda must take two arguments"
        case .missingLastExpression:
            return "[] Error: missing last expression"
        case .lastExpressionNeedsToBeWorld:
            return "[] Error: last expression needs to be world"
        case .couldNotEvaluateVariable(let nameToken):
            return "[\(nameToken.location)] Error: could not evaluate variable, \(nameToken.lexeme)"
        case .couldNotEvaluateFunction(let nameToken):
            return "[\(nameToken.location)] Error: could not evaluate function, \(nameToken.lexeme)"
        case .couldNotConstructLambda(let exprToken):
            return "[\(exprToken.location)] Error: could not construct lambda, \(exprToken.lexeme)"
        case .notAPureMathFunction(let objectName):
            return "[\(objectName.location())] Error: not a pure mathematical function, \(objectName)"
        }
    }
}
