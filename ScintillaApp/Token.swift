//
//  Token.swift
//  ScintillaApp
//
//  Created by Danielle Kefford on 1/22/25.
//

struct Token: CustomStringConvertible, Equatable, Hashable {
    let type: TokenType
    let lexeme: Substring

    init(type: TokenType, lexeme: Substring) {
        self.type = type
        self.lexeme = lexeme
    }

    var description: String {
        let location = lexeme.location()
        return "Location: (\(location.line), \(location.column)), type: \(type), lexeme: \(lexeme)"
    }
}
