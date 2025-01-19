//
//  ScintillaAppApp.swift
//  ScintillaApp
//
//  Created by Danielle Kefford on 1/17/25.
//

import SwiftUI
import UniformTypeIdentifiers

@main
struct ScintillaApp: App {
    var body: some Scene {
        DocumentGroup(newDocument: ScintillaDocument()) { file in
            ContentView(document: file.$document)
        }
    }
}
