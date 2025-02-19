//
//  Helpers.swift
//  ScintillaApp
//
//  Created by Danielle Kefford on 2/18/25.
//

public func makeLexeme(source: String, offset: Int, length: Int) -> Substring {
    let startIndex = source.index(source.startIndex, offsetBy: offset)
    let endIndex = source.index(startIndex, offsetBy: length)
    return source[startIndex..<endIndex]
}

