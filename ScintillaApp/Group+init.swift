//
//  Group+init.swift
//  ScintillaApp
//
//  Created by Danielle Kefford on 2/3/25.
//

import ScintillaLib

// ACHTUNG!!! This may be a temporary implementation until if/when
// ScintillaApp can somehow produce result builders
extension Group {
    init(children: [any Shape]) {
        self.init() {
            for child in children {
                child
            }
        }
    }
}
