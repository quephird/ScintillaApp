//
//  Token.swift
//  ScintillaApp
//
//  Created by Danielle Kefford on 1/22/25.
//

struct Token: CustomStringConvertible, Equatable, Hashable {
    let type: TokenType
    let lexeme: String
    let line: Int
    let column: Int

    init(type: TokenType, lexeme: String, line: Int, column: Int) {
        self.type = type
        self.lexeme = lexeme
        self.line = line
        self.column = column
    }

    var description: String {
        return "Location: (\(line), \(column)), type: \(type), lexeme: \(lexeme)"
    }
}
