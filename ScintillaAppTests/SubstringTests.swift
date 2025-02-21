//
//  SubstringTests.swift
//  ScintillaApp
//
//  Created by Danielle Kefford on 2/20/25.
//

import Testing
@testable import ScintillaApp

struct SubstringTests {
    @Test func getLocation() async throws {
        let source = """
let camera = Camera(
    width: 400,
    height: 400,
    viewAngle: PI/3,
    from: (0, 0, 5),
    to: (0, 0, 0),
    up: (0, 1, 0))

let lights = [
    PointLight(position: (10, 10, 10))
]

let shapes = [
    Sphere()
        .color(hsl: (0.5, 0.7, 0.8))
]

World(
    camera: camera,
    lights: lights,
    shapes: shapes)
"""
        let startIndex = source.index(source.startIndex, offsetBy: 58)
        let endIndex = source.index(source.startIndex, offsetBy: 67)
        let substring = source[startIndex..<endIndex]
        let actual = substring.location()
        let expected = SourceLocation(line: 4, column: 5)
        #expect(actual == expected)
    }
}
