//
//  ImageFocusedValueKey.swift
//  ScintillaApp
//
//  Created by Danielle Kefford on 1/28/25.
//

import SwiftUI

struct ImageFocusedValueKey: FocusedValueKey {
    typealias Value = Binding<CGImage?>
}

extension FocusedValues {
    var renderedImage: ImageFocusedValueKey.Value? {
        get {
            return self[ImageFocusedValueKey.self]
        }

        set {
            self[ImageFocusedValueKey.self] = newValue
        }
    }
}
