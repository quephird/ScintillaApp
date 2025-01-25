//
//  ParseError.swift
//  ScintillaApp
//
//  Created by Danielle Kefford on 1/23/25.
//

import Foundation

enum ParseError: CustomStringConvertible, LocalizedError {
    case missingVariableName(Token)
    case missingEquals(Token)
    case missingLeftParen(Token)
    case missingRightParen(Token)
    case missingRightBracket(Token)
    case missingColon(Token)
    case missingComma(Token)
    case missingIdentifier(Token)
    case expectedExpression(Token)

    var description: String {
        switch self {
        case .missingVariableName(let token):
            return "[\(token.location)] Error: expected variable name"
        case .missingEquals(let token):
            return "[\(token.location)] Error: expected equals sign in let statement"
        case .missingLeftParen(let token):
            return "[\(token.location)] Error: expected left parenthesis"
        case .missingRightParen(let token):
            return "[\(token.location)] Error: expected right parenthesis"
        case .missingRightBracket(let token):
            return "[\(token.location)] Error: expected right bracket"
        case .missingColon(let token):
            return "[\(token.location)] Error: expected colon"
        case .missingComma(let token):
            return "[\(token.location)] Error: expected comma"
        case .missingIdentifier(let token):
            return "[\(token.location)] Error: expected an identifier"
        case .expectedExpression(let token):
            return "[\(token.location)] Error: expected an expression"
        }
    }
}
