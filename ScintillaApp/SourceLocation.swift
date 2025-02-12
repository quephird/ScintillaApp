//
//  Location.swift
//  ScintillaApp
//
//  Created by Danielle Kefford on 1/22/25.
//

public struct SourceLocation: CustomStringConvertible {
    public let line: Int
    public let column: Int

    public var description: String {
        return "(\(line), \(column))"
    }
}
