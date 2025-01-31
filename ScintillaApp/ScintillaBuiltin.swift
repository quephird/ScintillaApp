//
//  ScintillaBuiltin.swift
//  ScintillaApp
//
//  Created by Danielle Kefford on 1/26/25.
//

import ScintillaLib

enum ScintillaBuiltin: CaseIterable, Equatable {
    case cube
    case plane
    case sphere
    case world
    case camera
    case pointLight
    case colorRgb
    case colorHsl
    case translate
    case scale
    case rotateX
    case rotateY
    case rotateZ
    case shear

    var objectName: ObjectName {
        switch self {
        case .cube:
            return .functionName("Cube", [])
        case .plane:
            return .functionName("Plane", [])
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
            return .methodName(.shape, "translate", ["x", "y", "z"])
        case .scale:
            return .methodName(.shape, "scale", ["x", "y", "z"])
        case .rotateX:
            return .methodName(.shape, "rotateX", ["theta"])
        case .rotateY:
            return .methodName(.shape, "rotateY", ["theta"])
        case .rotateZ:
            return .methodName(.shape, "rotateZ", ["theta"])
        case .shear:
            return .methodName(.shape, "shear", ["xy", "xz", "yx", "yz", "zx", "zy"])
        }
    }

    public func call(argumentValues: [ScintillaValue]) throws -> ScintillaValue {
        switch self {
        case .cube:
            return .shape(Cube())
        case .plane:
            return .shape(Plane())
        case .sphere:
            return .shape(Sphere())
        case .camera:
            return try makeCamera(argumentValues: argumentValues)
        case .pointLight:
            return try makePointLight(argumentValues: argumentValues)
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
        case .scale:
            return try makeScale(object: object, argumentValues: argumentValues)
        case .rotateX:
            return try makeRotateX(object: object, argumentValues: argumentValues)
        case .rotateY:
            return try makeRotateY(object: object, argumentValues: argumentValues)
        case .rotateZ:
            return try makeRotateZ(object: object, argumentValues: argumentValues)
        case .shear:
            return try makeRotateZ(object: object, argumentValues: argumentValues)
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

        let x = try extractRawDouble(argumentValue: argumentValues[0])
        let y = try extractRawDouble(argumentValue: argumentValues[1])
        let z = try extractRawDouble(argumentValue: argumentValues[2])

        return .shape(shape.translate(x, y, z))
    }

    private func makeScale(object: ScintillaValue,
                           argumentValues: [ScintillaValue]) throws -> ScintillaValue {
        guard case .shape(let shape) = object else {
            throw RuntimeError.incorrectObject
        }

        let x = try extractRawDouble(argumentValue: argumentValues[0])
        let y = try extractRawDouble(argumentValue: argumentValues[1])
        let z = try extractRawDouble(argumentValue: argumentValues[2])

        return .shape(shape.scale(x, y, z))
    }

    private func makeShear(object: ScintillaValue,
                           argumentValues: [ScintillaValue]) throws -> ScintillaValue {
        guard case .shape(let shape) = object else {
            throw RuntimeError.incorrectObject
        }

        let xy = try extractRawDouble(argumentValue: argumentValues[0])
        let xz = try extractRawDouble(argumentValue: argumentValues[1])
        let yx = try extractRawDouble(argumentValue: argumentValues[2])
        let yz = try extractRawDouble(argumentValue: argumentValues[3])
        let zx = try extractRawDouble(argumentValue: argumentValues[4])
        let zy = try extractRawDouble(argumentValue: argumentValues[5])

        return .shape(shape.shear(xy, xz, yx, yz, zx, zy))
    }

    private enum RotationAxis {
        case x, y, z
    }

    private func makeRotateX(object: ScintillaValue,
                             argumentValues: [ScintillaValue]) throws -> ScintillaValue {
        return try makeRotationCall(object: object,
                                    argumentValues: argumentValues,
                                    rotationAxis: .x)
    }

    private func makeRotateY(object: ScintillaValue,
                             argumentValues: [ScintillaValue]) throws -> ScintillaValue {
        return try makeRotationCall(object: object,
                                    argumentValues: argumentValues,
                                    rotationAxis: .y)
    }

    private func makeRotateZ(object: ScintillaValue,
                             argumentValues: [ScintillaValue]) throws -> ScintillaValue {
        return try makeRotationCall(object: object,
                                    argumentValues: argumentValues,
                                    rotationAxis: .z)
    }

    private func makeRotationCall(object: ScintillaValue,
                                  argumentValues: [ScintillaValue],
                                  rotationAxis: RotationAxis) throws -> ScintillaValue {
        guard case .shape(let shape) = object else {
            throw RuntimeError.incorrectObject
        }

        let theta = try extractRawDouble(argumentValue: argumentValues[0])

        return switch rotationAxis {
        case .x:
            .shape(shape.rotateX(theta))
        case .y:
            .shape(shape.rotateY(theta))
        case .z:
            .shape(shape.rotateZ(theta))
        }
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
