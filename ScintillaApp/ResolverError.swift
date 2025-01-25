//
//  ResolverError.swift
//  ScintillaApp
//
//  Created by Danielle Kefford on 1/25/25.
//

import Foundation

enum ResolverError: LocalizedError, CustomStringConvertible {
    case undefinedVariable(Token)
    case variableAccessedBeforeInitialization(Token)
    case variableAlreadyDefined(Token)

    var description: String {
        switch self {
        case .undefinedVariable(let token):
            return "[\(token.location)] Error: undefined variable, \(token.lexeme)"
        case .variableAccessedBeforeInitialization(let token):
            return "[\(token.location)] Error: cannot read local variable in its own initializer"
        case .variableAlreadyDefined(let token):
            return "[\(token.location)] Error: variable \(token.lexeme) already defined in this scope"
        }
    }
}
