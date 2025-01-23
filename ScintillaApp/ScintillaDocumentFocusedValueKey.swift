//
//  ScintillaDocumentFocusedValueKey.swift
//  ScintillaApp
//
//  Created by Danielle Kefford on 1/22/25.
//

import SwiftUI

struct ScintillaDocumentFocusedValueKey: FocusedValueKey {
    typealias Value = Binding<ScintillaDocument>
}

extension FocusedValues {
    var document: ScintillaDocumentFocusedValueKey.Value? {
        get {
            return self[ScintillaDocumentFocusedValueKey.self]
        }

        set {
            self[ScintillaDocumentFocusedValueKey.self] = newValue
        }
    }
}
