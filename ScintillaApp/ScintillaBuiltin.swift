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
        let firstArgumentValue = argumentValues[0]
        guard case .camera(let camera) = firstArgumentValue else {
            throw RuntimeError.incorrectArgument
        }

        let secondArgumentValue = argumentValues[1]
        guard case .list(let wrappedLights) = secondArgumentValue else {
            throw RuntimeError.incorrectArgument
        }
        let lights = try wrappedLights.map { wrappedLight in
            guard case .light(let light) = wrappedLight else {
                throw RuntimeError.incorrectArgument
            }

            return light
        }

        let thirdArgumentValue = argumentValues[2]
        guard case .list(let wrappedShapes) = thirdArgumentValue else {
            throw RuntimeError.incorrectArgument
        }
        let shapes = try wrappedShapes.map { wrappedShape in
            guard case .shape(let shape) = wrappedShape else {
                throw RuntimeError.incorrectArgument
            }

            return shape
        }

        let newWorld = World(camera, lights, shapes)
        return .world(newWorld)
    }

    private func makeCamera(argumentValues: [ScintillaValue]) throws -> ScintillaValue {
        let firstArgumentValue = argumentValues[0]
        guard case .double(let width) = firstArgumentValue else {
            throw RuntimeError.incorrectArgument
        }

        let secondArgumentValue = argumentValues[1]
        guard case .double(let height) = secondArgumentValue else {
            throw RuntimeError.incorrectArgument
        }

        let thirdArgumentValue = argumentValues[2]
        guard case .double(let viewAngle) = thirdArgumentValue else {
            throw RuntimeError.incorrectArgument
        }

        let fourthArgumentValue = argumentValues[3]
        guard case .tuple(let from) = fourthArgumentValue else {
            throw RuntimeError.incorrectArgument
        }
        guard case (.double(let fromX), .double(let fromY), .double(let fromZ)) = from else {
            throw RuntimeError.incorrectArgument
        }

        let fifthArgumentValue = argumentValues[4]
        guard case .tuple(let to) = fifthArgumentValue else {
            throw RuntimeError.incorrectArgument
        }
        guard case (.double(let toX), .double(let toY), .double(let toZ)) = to else {
            throw RuntimeError.incorrectArgument
        }

        let sixthArgumentValue = argumentValues[5]
        guard case .tuple(let up) = sixthArgumentValue else {
            throw RuntimeError.incorrectArgument
        }
        guard case (.double(let upX), .double(let upY), .double(let upZ)) = up else {
            throw RuntimeError.incorrectArgument
        }

        return .camera(Camera(width: Int(width),
                              height: Int(height),
                              viewAngle: viewAngle,
                              from: Point(fromX, fromY, fromZ),
                              to: Point(toX, toY, toZ),
                              up: Vector(upX, upY, upZ)))
    }

    private func makePointLight(argumentValues: [ScintillaValue]) throws -> ScintillaValue {
        let firstArgumentValue = argumentValues[0]
        guard case .tuple(let position) = firstArgumentValue else {
            throw RuntimeError.incorrectArgument
        }
        guard case (.double(let x), .double(let y), .double(let z)) = position else {
            throw RuntimeError.incorrectArgument
        }

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

        let firstArgumentValue = argumentValues[0]
        guard case .tuple(let color) = firstArgumentValue else {
            throw RuntimeError.incorrectArgument
        }

        guard case (.double(let h), .double(let s), .double(let l)) = color else {
            fatalError("Tuple should only ever have three double values")
        }

        let solidColor: Material = .solidColor(h, s, l, colorSpace)
        return .shape(shape.material(solidColor))
    }

    private func makeTranslate(object: ScintillaValue,
                               argumentValues: [ScintillaValue]) throws -> ScintillaValue {
        guard case .shape(let shape) = object else {
            throw RuntimeError.incorrectObject
        }

        let firstArgumentValue = argumentValues[0]
        guard case .tuple(let position) = firstArgumentValue else {
            throw RuntimeError.incorrectArgument
        }

        guard case (.double(let x), .double(let y), .double(let z)) = position else {
            fatalError("Tuple should only ever have three double values")
        }

        return .shape(shape.translate(x, y, z))
    }
}
