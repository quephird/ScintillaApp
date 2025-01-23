//
//  TokenizerError.swift
//  ScintillaApp
//
//  Created by Danielle Kefford on 1/22/25.
//

import Foundation

enum TokenizerError: CustomStringConvertible, Equatable, LocalizedError {
    case unexpectedCharacter(Token)
    case unterminatedComment(Token)

    var description: String {
        switch self {
        case .unexpectedCharacter(let token):
            return "[\(token.location)] Error: unexpected character, \"\(token.lexeme)\""
        case .unterminatedComment(let token):
            return "[\(token.location)] Error: unterminated comment"
        }
    }
}
