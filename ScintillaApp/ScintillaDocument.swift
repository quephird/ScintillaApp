//
//  ScintillaDocument.swift
//  ScintillaApp
//
//  Created by Danielle Kefford on 1/18/25.
//

import SwiftUI
import UniformTypeIdentifiers

struct ScintillaDocument: FileDocument {
    static var readableContentTypes: [UTType] { [.scintillaDocument] }
    static var sceneTemplate = """
let camera = Camera(
    width: <<enter integer value here>>,
    height: <<enter integer value here>>,
    viewAngle: <<enter double value here>>,
    from: <<enter tuple here>>,
    to: <<enter tuple here>>,
    up: <<enter tuple here>>)

let lights = [
    <<enter at least one light here>>
]

let shapes = [
    <<enter at least one shape here>>
]

World(
    camera: camera,
    lights: lights,
    shapes: shapes)
"""

    var text: String

    init() {
        self.text = Self.sceneTemplate
    }

    init(configuration: ReadConfiguration) throws {
        guard let data = configuration.file.regularFileContents,
              let text = String(data: data, encoding: .utf8)
        else {
            throw CocoaError(.fileReadCorruptFile)
        }

        self.text = text
    }

    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        let data = Data(text.utf8)
        return .init(regularFileWithContents: data)
    }
}
