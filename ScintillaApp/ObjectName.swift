//
//  VariableName.swift
//  ScintillaApp
//
//  Created by Danielle Kefford on 1/25/25.
//

enum ObjectName: Hashable {
    case variableName(Substring)
    case functionName(Substring, [Substring])
}
