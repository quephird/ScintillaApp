//
//  CGImage+id.swift
//  ScintillaApp
//
//  Created by Danielle Kefford on 1/29/25.
//

import AppKit

extension CGImage: @retroactive Identifiable {
    public var id: ObjectIdentifier {
        ObjectIdentifier(self)
    }
}
