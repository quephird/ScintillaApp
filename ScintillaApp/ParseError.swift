//
//  ParseError.swift
//  ScintillaApp
//
//  Created by Danielle Kefford on 1/23/25.
//

import Foundation

enum ParseError: CustomStringConvertible, Equatable, LocalizedError {
    case missingVariableName(Token)
    case missingFunctionName(Token)
    case missingEquals(Token)
    case missingLeftParen(Token)
    case missingRightParen(Token)
    case missingLeftBrace(Token)
    case missingRightBrace(Token)
    case missingRightBracket(Token)
    case missingColon(Token)
    case missingComma(Token)
    case missingIdentifier(Token)
    case missingIn(Token)
    case expectedExpression(Token)

    var description: String {
        switch self {
        case .missingVariableName(let token):
            return "[\(token.location)] Error: expected variable name"
        case .missingFunctionName(let token):
            return "[\(token.location)] Error: expected function name"
        case .missingEquals(let token):
            return "[\(token.location)] Error: expected equals sign in let statement"
        case .missingLeftParen(let token):
            return "[\(token.location)] Error: expected left parenthesis"
        case .missingRightParen(let token):
            return "[\(token.location)] Error: expected right parenthesis"
        case .missingLeftBrace(let token):
            return "[\(token.location)] Error: expected left brace"
        case .missingRightBrace(let token):
            return "[\(token.location)] Error: expected right brace"
        case .missingRightBracket(let token):
            return "[\(token.location)] Error: expected right bracket"
        case .missingColon(let token):
            return "[\(token.location)] Error: expected colon"
        case .missingComma(let token):
            return "[\(token.location)] Error: expected comma"
        case .missingIdentifier(let token):
            return "[\(token.location)] Error: expected an identifier"
        case .missingIn(let token):
            return "[\(token.location)] Error: expected keyword `in`"
        case .expectedExpression(let token):
            return "[\(token.location)] Error: expected an expression"
        }
    }
}
