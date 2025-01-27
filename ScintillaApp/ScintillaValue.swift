//
//  ScintillaValue.swift
//  ScintillaApp
//
//  Created by Danielle Kefford on 1/23/25.
//

enum ScintillaValue: Equatable, CustomStringConvertible {
    case double(Double)
    case list([ScintillaValue])
    indirect case tuple((ScintillaValue, ScintillaValue, ScintillaValue))
    case function(ScintillaBuiltin)

    static func == (lhs: ScintillaValue, rhs: ScintillaValue) -> Bool {
        switch (lhs, rhs) {
        case (.double(let l), .double(let r)):
            return l == r
        case (.list(let l), .list(let r)):
            return l == r
        case (.tuple(let l), .tuple(let r)):
            return l == r
        case (.function(let l), .function(let r)):
            return l == r
        default:
            return false
        }
    }

    var description: String {
        switch self {
        case .double(let value):
            return "\(value)"
        case .list(let values):
            return values.map { "\($0)" }.joined(separator: ", ")
        case .tuple(let values):
            return "(\(values.0), \(values.1), \(values.2))"
        case .function(let builtin):
            return "\(builtin.objectName)"
        }
    }
}
