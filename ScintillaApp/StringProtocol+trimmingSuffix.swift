//
//  StringProtocol+trimmingSuffix.swift
//  ScintillaApp
//
//  Created by Danielle Kefford on 2/17/25.
//

extension StringProtocol {
    public func trimmingSuffix(while predicate: (Character) -> Bool) -> SubSequence {
        guard let lastCharIndex = self.lastIndex(where: { char in !predicate(char) }) else {
            return ""
        }

        return self[...lastCharIndex]
    }
}
