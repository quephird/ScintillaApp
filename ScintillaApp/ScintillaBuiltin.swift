//
//  ScintillaBuiltin.swift
//  ScintillaApp
//
//  Created by Danielle Kefford on 1/26/25.
//

import ScintillaLib

enum ScintillaBuiltin: CaseIterable, Equatable {
    case sphere
    case world
    case camera
    case pointLight
    case colorRgb
    case colorHsl
    case translate

    var objectName: ObjectName {
        switch self {
        case .sphere:
            return .functionName("Sphere", [])
        case .world:
            return .functionName("World", ["camera", "lights", "shapes"])
        case .camera:
            return .functionName("Camera", ["width", "height", "viewAngle", "from", "to", "up"])
        case .pointLight:
            return .functionName("PointLight", ["position"])
        case .colorRgb:
            return .methodName(.shape, "color", ["rgb"])
        case .colorHsl:
            return .methodName(.shape, "color", ["hsl"])
        case .translate:
            return .methodName(.shape, "translate", ["by"])
        }
    }

    public func call(argumentValues: [ScintillaValue]) throws -> ScintillaValue {
        switch self {
        case .camera:
            return try makeCamera(argumentValues: argumentValues)
        case .pointLight:
            return try makePointLight(argumentValues: argumentValues)
        case .sphere:
            return .shape(Sphere())
        case .world:
            return try makeWorld(argumentValues: argumentValues)
        default:
            fatalError("Internal error: method calls should not get here")
        }
    }

    public func callMethod(object: ScintillaValue, argumentValues: [ScintillaValue]) throws -> ScintillaValue {
        switch self {
        case .colorRgb:
            return try makeColorRgb(object: object, argumentValues: argumentValues)
        case .colorHsl:
            return try makeColorHsl(object: object, argumentValues: argumentValues)
        case .translate:
            return try makeTranslate(object: object, argumentValues: argumentValues)
        default:
            fatalError("Internal error: only method calls should ever get here")
        }
    }

    private func makeWorld(argumentValues: [ScintillaValue]) throws -> ScintillaValue {
        let camera = try extractRawCamera(argumentValue: argumentValues[0])
        let lights = try extractRawLights(argumentValue: argumentValues[1])
        let shapes = try extractRawShapes(argumentValue: argumentValues[2])

        let newWorld = World(camera, lights, shapes)
        return .world(newWorld)
    }

    private func makeCamera(argumentValues: [ScintillaValue]) throws -> ScintillaValue {
        let width = try extractRawDouble(argumentValue: argumentValues[0])
        let height = try extractRawDouble(argumentValue: argumentValues[1])
        let viewAngle = try extractRawDouble(argumentValue: argumentValues[2])
        let (fromX, fromY, fromZ) = try extractRawTuple(argumentValue: argumentValues[3])
        let (toX, toY, toZ) = try extractRawTuple(argumentValue: argumentValues[4])
        let (upX, upY, upZ) = try extractRawTuple(argumentValue: argumentValues[5])

        return .camera(Camera(width: Int(width),
                              height: Int(height),
                              viewAngle: viewAngle,
                              from: Point(fromX, fromY, fromZ),
                              to: Point(toX, toY, toZ),
                              up: Vector(upX, upY, upZ)))
    }

    private func makePointLight(argumentValues: [ScintillaValue]) throws -> ScintillaValue {
        let (x, y, z) = try extractRawTuple(argumentValue: argumentValues[0])

        let point = Point(x, y, z)
        return .light(PointLight(position: point))
    }

    private func makeColorRgb(object: ScintillaValue,
                              argumentValues: [ScintillaValue]) throws -> ScintillaValue {
        return try makeColorFunctionCall(object: object,
                                         argumentValues: argumentValues,
                                         colorSpace: .rgb)
    }

    private func makeColorHsl(object: ScintillaValue,
                              argumentValues: [ScintillaValue]) throws -> ScintillaValue {
        return try makeColorFunctionCall(object: object,
                                         argumentValues: argumentValues,
                                         colorSpace: .hsl)
    }

    private func makeColorFunctionCall(object: ScintillaValue,
                                       argumentValues: [ScintillaValue],
                                       colorSpace: ColorSpace) throws -> ScintillaValue {
        guard case .shape(let shape) = object else {
            throw RuntimeError.incorrectObject
        }

        let (colorComponent0, colorComponent1, colorComponent2) = try extractRawTuple(argumentValue: argumentValues[0])

        let solidColor: Material = .solidColor(colorComponent0, colorComponent1, colorComponent2, colorSpace)
        return .shape(shape.material(solidColor))
    }

    private func makeTranslate(object: ScintillaValue,
                               argumentValues: [ScintillaValue]) throws -> ScintillaValue {
        guard case .shape(let shape) = object else {
            throw RuntimeError.incorrectObject
        }

        let (x, y, z) = try extractRawTuple(argumentValue: argumentValues[0])

        return .shape(shape.translate(x, y, z))
    }

    private func extractRawDouble(argumentValue: ScintillaValue) throws -> Double {
        guard case .double(let rawDouble) = argumentValue else {
            throw RuntimeError.expectedDouble
        }

        return rawDouble
    }

    private func extractRawTuple(argumentValue: ScintillaValue) throws -> (Double, Double, Double) {
        guard case .tuple(let tuple) = argumentValue else {
            throw RuntimeError.expectedTuple
        }

        guard case (.double(let rawDouble0), .double(let rawDouble1), .double(let rawDouble2)) = tuple else {
            fatalError("Tuple should only ever have three double values")
        }

        return (rawDouble0, rawDouble1, rawDouble2)
    }

    private func extractRawCamera(argumentValue: ScintillaValue) throws -> Camera {
        guard case .camera(let rawCamera) = argumentValue else {
            throw RuntimeError.expectedCamera
        }

        return rawCamera
    }

    private func extractRawLights(argumentValue: ScintillaValue) throws -> [any Light] {
        guard case .list(let wrappedLights) = argumentValue else {
            throw RuntimeError.incorrectArgument
        }

        let lights = try wrappedLights.map { wrappedLight in
            guard case .light(let light) = wrappedLight else {
                throw RuntimeError.expectedLight
            }

            return light
        }

        return lights
    }

    private func extractRawShapes(argumentValue: ScintillaValue) throws -> [any Shape] {
        guard case .list(let wrappedShapes) = argumentValue else {
            throw RuntimeError.incorrectArgument
        }

        let shapes = try wrappedShapes.map { wrappedShape in
            guard case .shape(let shape) = wrappedShape else {
                throw RuntimeError.expectedShape
            }

            return shape
        }

        return shapes
    }
}
