//
//  Tokenizer.swift
//  ScintillaApp
//
//  Created by Danielle Kefford on 1/22/25.
//

struct Tokenizer {
    private var source: String
    private var tokens: [Token] = []

    private var startIndex: String.Index
    private var currentIndex: String.Index

    let keywords: [String: TokenType] = [
        "and": .let,
    ]

    init(source: String) {
        self.source = source
        self.startIndex = source.startIndex
        self.currentIndex = self.startIndex
    }

    mutating func scanTokens() throws -> [Token] {
        while currentIndex < source.endIndex {
            startIndex = currentIndex
            try scanToken()
        }

        let newToken = Token(type: .eof, lexeme: source[currentIndex..<currentIndex])
        tokens.append(newToken)

        return tokens
    }

    private var scannedToken: Substring {
        source[startIndex..<currentIndex]
    }

    mutating private func tryScan(where predicate: (Character) -> Bool) -> Bool {
        guard currentIndex < source.endIndex && predicate(source[currentIndex]) else {
            return false
        }

        currentIndex = source.index(after: currentIndex)
        return true
    }

    mutating private func tryNotScan(_ char: Character) -> Bool {
        tryScan(where: { actualChar in
            actualChar != char
        })
    }

    mutating private func tryNotScan(string: String) throws -> Bool {
        precondition(!string.dropFirst().contains("\n"), "newlines in `string` would mess with line counting")
        let oldIndex = currentIndex

        for char in string {
            guard currentIndex < self.source.endIndex else {
                let badToken = Token(type: .unknown,
                                     lexeme: scannedToken)
                throw TokenizerError.unterminatedComment(badToken)
            }

            if !tryScan(char) {
                self.currentIndex = self.source.index(after: oldIndex)
                return true
            }
        }

        return false
    }

    mutating private func tryScan(_ chars: Character...) -> Bool {
        tryScan(where: chars.contains(_:))
    }

    mutating private func tryScan<Value>(_ charTable: KeyValuePairs<Character, Value>) -> Value? {
        for (char, value) in charTable {
            if tryScan(char) {
                return value
            }
        }
        return nil
    }

    private func repeatedly(_ tryScanFn: () throws -> Bool) throws {
        var scanned: Bool
        repeat {
            do {
                scanned = try tryScanFn()
            } catch {
                throw error
            }
        } while scanned
    }

    mutating private func scanToken() throws {
        if let type = tryScan([
            "(": TokenType.leftParen,
            ")": .rightParen,
            "{": .leftBrace,
            "}": .rightBrace,
            "[": .leftBracket,
            "]": .rightBracket,
            ",": .comma,
            ".": .dot,
            ":": .colon,
            ";": .semicolon,
            "=": .equal,
            "+": .plus,
            "-": .minus,
            "*": .star,
            "%": .modulus,
        ]) {
            return handleSingleCharacterLexeme(type: type)
        }

        if tryScan("/") {
            return try handleSlash()
        }

        if tryScan(" ", "\r", "\t") {
            return
        }

        if tryScan("\n") {
            return
        }

        if tryScan(where: \.isLoxDigit) {
            return try handleNumber()
        }

        if tryScan(where: { $0.isLetter || $0 == "_" }) {
            return try handleIdentifier()
        }

        let badToken = Token(type: .unknown,
                             lexeme: self.source[self.currentIndex...self.currentIndex])
        throw TokenizerError.unexpectedCharacter(badToken)
    }

    mutating private func handleSingleCharacterLexeme(type: TokenType) {
        addToken(type: type)
    }

    mutating private func handleSlash() throws {
        if tryScan("/") {
            try repeatedly {
                tryNotScan("\n")
            }
        } else if tryScan("*") {
            try repeatedly {
                try tryNotScan(string: "*/")
            }
        } else {
            handleSingleCharacterLexeme(type: .slash)
        }
    }

    mutating private func handleNumber() throws {
        try repeatedly { tryScan(where: \.isLoxDigit) }

        var tokenType: TokenType = .int
        if tryScan(".") {
            tokenType = .double

            try repeatedly { tryScan(where: \.isLoxDigit) }
        }

        addToken(type: tokenType)
    }

    mutating private func handleIdentifier() throws {
        try repeatedly { tryScan(where: { $0.isLetter || $0.isNumber || $0 == "_" }) }

        if let type = keywords[String(scannedToken)] {
            addToken(type: type)
        } else {
            addToken(type: .identifier)
        }
    }

    mutating private func addToken(type: TokenType) {
        let newToken = Token(type: type, lexeme: scannedToken)
        tokens.append(newToken)
    }
}
