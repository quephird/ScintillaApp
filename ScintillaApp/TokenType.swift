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
    case comma
    case dot
    case semicolon
    case leftBracket
    case rightBracket
    case modulus
    case colon
    case equal
    case minus
    case plus
    case slash
    case star

    // Literals
    case identifier
    case string
    case double
    case int

    // Keywords
    case `let`

    case eof
}
