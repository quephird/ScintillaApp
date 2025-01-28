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
}
