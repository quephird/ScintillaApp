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
        return "Location: \(self.location), type: \(self.type), lexeme: \(self.lexeme)"
    }

    var location: Location {
        self.lexeme.location()
    }
}
