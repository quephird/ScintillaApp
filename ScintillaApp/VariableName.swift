//
//  VariableName.swift
//  ScintillaApp
//
//  Created by Danielle Kefford on 1/25/25.
//

struct VariableName: Hashable {
    public var baseName: String
    public var argumentNames: [String]?

    init(baseName: Substring, argumentNames: [Substring]?) {
        self.baseName = String(baseName)

        if let argumentNames {
            self.argumentNames =  argumentNames.map { String($0) }
        }
    }
}
