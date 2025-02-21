//
//  EvaluatorTests.swift
//  ScintillaApp
//
//  Created by Danielle Kefford on 2/19/25.
//

import Testing
@testable import ScintillaApp
@_spi(Testing) @testable import ScintillaLib

struct EvaluatorTests {
    @Test func evaluateBoolean() async throws {
        let source = """
false
"""

        let evaluator = Evaluator()
        let actualResult = try evaluator.interpretRaw(source: source)
        let actualValue = actualResult.getBoolean()
        #expect(false == actualValue)
    }

    @Test func evaluateDouble() async throws {
        let source = """
(2 + 4) * 7
"""

        let evaluator = Evaluator()
        let actualResult = try evaluator.interpretRaw(source: source)
        let actualValue = try #require(actualResult.getDouble())
        #expect(42 == actualValue)
    }

    @Test func evaluateTuple2() async throws {
        let source = """
(1, 2)
"""

        let evaluator = Evaluator()
        let actualResult = try evaluator.interpretRaw(source: source)
        let firstValue = try #require(actualResult.getTuple2()).0.getDouble()
        let secondValue = try #require(actualResult.getTuple2()).1.getDouble()
        #expect(firstValue == 1 && secondValue == 2)
    }

    @Test func evaluateTuple3() async throws {
        let source = """
(2, 3, 4)
"""

        let evaluator = Evaluator()
        let actualResult = try evaluator.interpretRaw(source: source)
        let firstValue = try #require(actualResult.getTuple3()).0.getDouble()
        let secondValue = try #require(actualResult.getTuple3()).1.getDouble()
        let thirdValue = try #require(actualResult.getTuple3()).2.getDouble()
        #expect(firstValue == 2 && secondValue == 3 && thirdValue == 4)
    }

    @Test func evaluateCallOfBuiltin() async throws {
        let source = """
sin(PI/4)
"""

        let evaluator = Evaluator()
        let actualResult = try evaluator.interpretRaw(source: source)
        let actualValue = actualResult.getDouble()!
        #expect((2.squareRoot()/2).isAlmostEqual(actualValue))
    }

    @Test func evaluateUserDefinedFunction() async throws {
        let source = """
func multiply(a, b) {
    a * b
}

multiply(a: 6, b: 7)
"""

        let evaluator = Evaluator()
        let actualResult = try evaluator.interpretRaw(source: source)
        let actualValue = actualResult.getDouble()
        #expect(42 == actualValue)
    }

    @Test func evaluateLambda() async throws {
        let source = """
{ u, v in cos(u)*sin(v) }
"""

        let evaluator = Evaluator()
        let actualResult = try evaluator.interpretRaw(source: source)
        let actualLambda = try #require(actualResult.getLambda())
        let actualValue = try! actualLambda.call(evaluator: evaluator, argumentValues: PI/4, PI/4, 0.0)
        #expect(0.5 == actualValue)
    }

    @Test func evaluateSphereWithMethodCalls() throws {
        let source = """
Sphere()
    .color(hsl: (0.2, 0.3, 0.4))
    .translate(x: 1.0, y: 2.0, z: 3.0)
"""

        let evaluator = Evaluator()
        let actualResult = try evaluator.interpretRaw(source: source)
        let actualShape = try #require(actualResult.getShape(shapeType: Sphere.self))

        let material = try #require(actualShape.material as? SolidColor)
        #expect(material.color == .fromHsl(0.2, 0.3, 0.4))

        let transform = try #require(actualShape.transform)
        #expect(transform == .translation(1.0, 2.0, 3.0))
    }

    @Test func evaluateSingleLight() throws {
        let source = """
PointLight(position: (-5.0, 0.0, 3.0))
"""

        let evaluator = Evaluator()
        let actualResult = try evaluator.interpretRaw(source: source)
        let actualLight = try #require(actualResult.getLight(lightType: PointLight.self))

        #expect(actualLight.position == Point(-5.0, 0.0, 3.0))

    }

    @Test func evaluateSingleCamera() throws {
        let source = """
Camera(
    width: 400,
    height: 400,
    viewAngle: PI/3,
    from: (0, 0, 5),
    to: (0, 0, 0),
    up: (0, 1, 0))
"""

        let evaluator = Evaluator()
        let actualResult = try evaluator.interpretRaw(source: source)
        let actualCamera = try #require(actualResult.getCamera())

        let expectedCamera = Camera(
            width: 400,
            height: 400,
            viewAngle: PI/3,
            from: Point(0, 0, 5),
            to: Point(0, 0, 0),
            up: Vector(0, 1, 0))

        #expect(actualCamera == expectedCamera)
    }

    @Test func evaluateMinimalProgram() async throws {
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

        let evaluator = Evaluator()
        let actualWorld = try evaluator.interpret(source: source)
        let expectedCamera = Camera(
            width: 400,
            height: 400,
            viewAngle: PI/3,
            from: Point(0, 0, 5),
            to: Point(0, 0, 0),
            up: Vector(0, 1, 0))
        #expect(await actualWorld.camera == expectedCamera)
        #expect(await actualWorld.lights.count > 0)
        #expect(await actualWorld.shapes.count > 0)
    }

    @Test func evaluateBadProgram() throws {
        let source = """
Sphere()
    .color(hsl: (0.2, 0.3, 0.4))
"""

        let evaluator = Evaluator()
        #expect(throws: RuntimeError.lastExpressionNeedsToBeWorld) {
            try evaluator.interpret(source: source)
        }
    }
}
