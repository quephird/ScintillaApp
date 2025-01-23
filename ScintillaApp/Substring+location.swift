//
//  Substring+location.swift
//  ScintillaApp
//
//  Created by Danielle Kefford on 1/22/25.
//

public typealias Location = (line: Int, column: Int)

extension Substring {
    public func location() -> Location {
        var line: Int = 1
        var column: Int = 1

        for character in self.base[..<self.startIndex] {
            if character == "\n" {
                line += 1
                column = 1
            } else {
                column += 1
            }
        }

        return (line: line, column: column)
    }
}
