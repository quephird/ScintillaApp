//
//  UTType+scintillaDocument.swift
//  ScintillaApp
//
//  Created by Danielle Kefford on 1/18/25.
//

import UniformTypeIdentifiers

// This app's document type.
extension UTType {
    static var scintillaDocument: UTType {
        UTType(exportedAs: "com.quephird.scintillaDocument")
    }
}
