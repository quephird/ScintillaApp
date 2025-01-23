//
//  TokenizerError.swift
//  ScintillaApp
//
//  Created by Danielle Kefford on 1/22/25.
//

import Foundation

enum TokenizerError: CustomStringConvertible, Equatable, LocalizedError {
    case unterminatedString(Int, Int)
    case unexpectedCharacter(Int, Int, Character)
    case unterminatedComment(Int, Int)

    var description: String {
        switch self {
        case .unterminatedString(let line, let column):
            return "[(\(line), \(column))] Error: unterminated string"
        case .unexpectedCharacter(let line, let column, let character):
            return "[(\(line), \(column))] Error: unexpected character, \"\(character)\""
        case .unterminatedComment(let line, let column):
            return "[(\(line), \(column))] Error: unterminated comment"
        }
    }
}
