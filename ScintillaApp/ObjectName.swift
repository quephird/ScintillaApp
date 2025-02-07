//
//  VariableName.swift
//  ScintillaApp
//
//  Created by Danielle Kefford on 1/25/25.
//

enum ObjectName: Hashable {
    case variableName(Substring)
    case functionName(Substring, [Substring])
    case methodName(ScintillaType, Substring, [Substring])
}

extension ObjectName: CustomStringConvertible {
    var description: String {
        switch self {
        case .variableName(let name):
            return String(name)
        case .functionName(let name, _):
            // TODO: Follow orders from my PM and interpolate argument names as well 🫡
            return String(name)
        case .methodName(_, let name, _):
            // TODO: Follow orders from my PM and interpolate argument names as well 🫡
            return String(name)
        }
    }
}

extension ObjectName {
    public func location() -> Location {
        switch self {
        case .variableName(let name):
            return name.location()
        case .functionName(let name, _):
            return name.location()
        case .methodName(_, let name, _):
            return name.location()
        }
    }
}
