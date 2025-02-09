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
        case .functionName(let name, let argumentNames):
            let argumentList = self.argumentList(argumentNames: argumentNames)
            return "\(name)(\(argumentList))"
        case .methodName(_, let name, let argumentNames):
            let argumentList = self.argumentList(argumentNames: argumentNames)
            return "\(name)(\(argumentList))"
        }
    }

    private func argumentList(argumentNames: [Substring]) -> String {
        argumentNames
            .map { "\($0):" }
            .joined(separator: ",")
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
