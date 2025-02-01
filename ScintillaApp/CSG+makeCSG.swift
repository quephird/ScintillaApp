//
//  CSG+makeCSG.swift
//  ScintillaApp
//
//  Created by Danielle Kefford on 1/31/25.
//

import ScintillaLib

// ACHTUNG!!! This may be a temporary implementation until if/when
// ScintillaApp can somehow result builders
extension CSG {
    static func makeCSG(_ operation: Operation,
                        _ baseShape: any Shape,
                        _ rightShapes: [any Shape]) -> any Shape {
        return rightShapes.reduce(baseShape) { partialResult, rightShape in
            CSG(operation, partialResult, rightShape)
        }
    }
}
