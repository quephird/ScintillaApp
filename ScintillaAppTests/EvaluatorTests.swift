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
sin(pi/4)
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

    @Test func evaluateSingleColor() throws {
        let source = """
Color(r: 0.2, g: 0.3, b: 0.4))
"""

        let evaluator = Evaluator()
        let actualResult = try evaluator.interpretRaw(source: source)
        let actualColor = try #require(actualResult.getColor())

        #expect(actualColor.r == 0.2)
        #expect(actualColor.g == 0.3)
        #expect(actualColor.b == 0.4)
    }

    @Test func evaluateUniformMaterial() throws {
        let source = """
Uniform(
    Color(h: 0.2, s: 0.3, l: 0.4))
"""

        let evaluator = Evaluator()
        let actualResult = try evaluator.interpretRaw(source: source)
        let actualMaterial = try #require(actualResult.getMaterial(materialType: Uniform.self))

        #expect(actualMaterial.color == .fromHsl(0.2, 0.3, 0.4))
    }

    @Test func evaluateCheckered3DMaterialWithTransform() throws {
        let source = """
Checkered3D(
    firstColor: Color(r: 0.0, g: 0.0, b: 0.0),
    secondColor: Color(r: 1.0, g: 1.0, b: 1.0))
    .rotateY(pi/4)
"""

        let evaluator = Evaluator()
        let actualResult = try evaluator.interpretRaw(source: source)
        let actualMaterial = try #require(actualResult.getMaterial(materialType: Checkered3D.self))

        #expect(actualMaterial.firstColor == Color(0.0, 0.0, 0.0))
        #expect(actualMaterial.secondColor == Color(1.0, 1.0, 1.0))
        #expect(actualMaterial.transform == .rotationY(PI/4))
    }

    @Test func evaluateSphereWithMethodCalls() throws {
        let source = """
Sphere()
    .material(Uniform(Color(h: 0.2, s: 0.3, l: 0.4)))
    .translate(x: 1.0, y: 2.0, z: 3.0)
"""

        let evaluator = Evaluator()
        let actualResult = try evaluator.interpretRaw(source: source)
        let actualShape = try #require(actualResult.getShape(shapeType: Sphere.self))

        let material = try #require(actualShape.material as? Uniform)
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
    viewAngle: pi/3,
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

    @Test func evaluateListConcatenation() throws {
        let source = """
let foo = [1, 2, 3]
let bar = [4, 5, 6]
foo + bar
"""

        let evaluator = Evaluator()
        let actualResult = try evaluator.interpretRaw(source: source)
        let actualList = try #require(actualResult.getList())
        let expectedList: [ScintillaValue] = [
            .double(Double(1)),
            .double(Double(2)),
            .double(Double(3)),
            .double(Double(4)),
            .double(Double(5)),
            .double(Double(6))
        ]

        #expect(actualList == expectedList)
    }

    @Test func evaluateListIteration() throws {
        let source = """
let red = Uniform(Color(r: 1.0, g: 0.0, b: 0.0))
let green = Uniform(Color(r: 0.0, g: 1.0, b: 0.0))
let blue = Uniform(Color(r: 0.0, g: 0.0, b: 1.0))

let colors = [red, green, blue]

colors.eachWithIndex({i, color in
    Sphere()
        .material(color)
        .translate(x: i-1, y: 0.0, z: 0.0)
})
"""

        let evaluator = Evaluator()
        let result = try evaluator.interpretRaw(source: source)
        let list = try #require(result.getList())

        let actualColors = try list.map { element in
            let sphere = try #require(element.getShape(shapeType: Sphere.self))
            return sphere.sharedProperties.material as! Uniform
        }
        let expectedColors = [
            Uniform(Color(1.0, 0.0, 0.0)),
            Uniform(Color(0.0, 1.0, 0.0)),
            Uniform(Color(0.0, 0.0, 1.0)),
        ]
        #expect(actualColors == expectedColors)

        let actualTransforms = try list.map { element in
            let sphere = try #require(element.getShape(shapeType: Sphere.self))
            return sphere.sharedProperties.transform
        }
        let expectedTransforms: [Matrix4] = [
            .translation(-1.0, 0.0, 0.0),
            .translation(0.0, 0.0, 0.0),
            .translation(1.0, 0.0, 0.0),
        ]
        #expect(actualTransforms == expectedTransforms)
    }

    @Test func evaluateBadBinaryExpression() async throws {
        let source = """
[1, 2, 3] + 4
"""

        let evaluator = Evaluator()
        let expectedError = RuntimeError.binaryOperandsMustBeNumbersOrLists(
            SourceLocation(line: 1, column: 11), "+")
        #expect(throws: expectedError) {
            try evaluator.interpret(source: source)
        }
    }

    @Test func testFunctionWithDestructuredParameter() async throws {
        let source = """
func foo(a, (b, c) as d) {
    a + b + c
}

foo(a: 1, d: (2, 3))
"""

        let evaluator = Evaluator()
        let actualResult = try evaluator.interpretRaw(source: source)
        let expectedResult: ScintillaValue = .double(Double(6))

        #expect(actualResult == expectedResult)
    }

    @Test func evaluateMinimalProgram() async throws {
        let source = """
let camera = Camera(
    width: 400,
    height: 400,
    viewAngle: pi/3,
    from: (0, 0, 5),
    to: (0, 0, 0),
    up: (0, 1, 0))

let lights = [
    PointLight(position: (10, 10, 10))
]

let turquoise = Uniform(
    Color(h: 0.5, s: 0.7, l: 0.8))

let shapes = [
    Sphere()
        .material(turquoise)
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
let olive = Uniform(
    Color(h: 0.2, s: 0.3, l: 0.4))

Sphere()
    .material(olive)
"""

        let evaluator = Evaluator()
        #expect(throws: RuntimeError.lastExpressionNeedsToBeWorld) {
            try evaluator.interpret(source: source)
        }
    }
}
