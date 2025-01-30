//
//  ScintillaDocumentFocusedValueKey.swift
//  ScintillaApp
//
//  Created by Danielle Kefford on 1/22/25.
//

import SwiftUI

extension FocusedValues {
    @Entry var document: Binding<ScintillaDocument>? = nil
    @Entry var viewModel: Binding<ViewModel>? = nil
}
