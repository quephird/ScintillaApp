//
//  TokenType.swift
//  ScintillaApp
//
//  Created by Danielle Kefford on 1/22/25.
//

enum TokenType: Equatable {
    // Single-character tokens
    case leftParen
    case rightParen
    case leftBrace
    case rightBrace
    case leftBracket
    case rightBracket
    case comma
    case dot
    case colon
    case equal
    case plus
    case minus
    case star
    case slash
    case caret

    // Special case
    case underscore

    // Literals
    case identifier
    case double

    // Keywords
    case `false`
    case `func`
    case `in`
    case `let`
    case `true`
    case `as`

    // Used for bad tokens
    case unknown

    case eof
}
