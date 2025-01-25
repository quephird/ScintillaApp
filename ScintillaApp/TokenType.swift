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
    case semicolon
    case equal
    case plus
    case minus
    case star
    case slash
    case modulus

    // Literals
    case identifier
    case double

    // Keywords
    case `let`

    // Used for bad tokens
    case unknown

    case eof
}
