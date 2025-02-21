//
//  Character+isLoxDigit.swift
//  ScintillaApp
//
//  Created by Danielle Kefford on 1/23/25.
//

extension Character {
    var isScintillaDigit: Bool {
        return self.isASCII && self.isNumber
    }
}
