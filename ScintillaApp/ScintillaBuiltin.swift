//
//  ScintillaBuiltin.swift
//  ScintillaApp
//
//  Created by Danielle Kefford on 1/26/25.
//

import ScintillaLib

enum ScintillaBuiltin: CaseIterable, Equatable {
    case cone
    case cube
    case cylinder
    case group
    case implicitSurface
    case plane
    case prism
    case sphere
    case superellipsoid
    case surfaceOfRevolution
    case torus
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
    case difference
    case intersection
    case union

    var objectName: ObjectName {
        switch self {
        case .cone:
            return .functionName("Cone", ["bottomY", "topY", "isCapped"])
        case .cube:
            return .functionName("Cube", [])
        case .cylinder:
            return .functionName("Cylinder", ["bottomY", "topY", "isCapped"])
        case .group:
            return .functionName("Group", ["children"])
        case .implicitSurface:
            return .functionName("ImplicitSurface", ["bottomFrontLeft", "topBackRight", "function"])
        case .plane:
            return .functionName("Plane", [])
        case .prism:
            return .functionName("Prism", ["bottomY", "topY", "xzPoints"])
        case .sphere:
            return .functionName("Sphere", [])
        case .superellipsoid:
            return .functionName("Superellipsoid", ["e", "n"])
        case .surfaceOfRevolution:
            return .functionName("SurfaceOfRevolution", ["yzPoints", "isCapped"])
        case .torus:
            return .functionName("Torus", ["majorRadius", "minorRadius"])
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
        case .difference:
            return .methodName(.shape, "difference", ["shapes"])
        case .intersection:
            return .methodName(.shape, "intersection", ["shapes"])
        case .union:
            return .methodName(.shape, "union", ["shapes"])
        }
    }

    public func call(argumentValues: [ScintillaValue]) throws -> ScintillaValue {
        switch self {
        case .cone:
            return try makeCone(argumentValues: argumentValues)
        case .cube:
            return .shape(Cube())
        case .cylinder:
            return try makeCylinder(argumentValues: argumentValues)
        case .group:
            return try makeGroup(argumentValues: argumentValues)
        case .implicitSurface:
            return try makeImplicitSurface(argumentValues: argumentValues)
        case .plane:
            return .shape(Plane())
        case .prism:
            return try makePrism(argumentValues: argumentValues)
        case .sphere:
            return .shape(Sphere())
        case .superellipsoid:
            return try makeSuperellipsoid(argumentValues: argumentValues)
        case .surfaceOfRevolution:
            return try makeSurfaceOfRevolution(argumentValues: argumentValues)
        case .torus:
            return try makeTorus(argumentValues: argumentValues)
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
        case .difference:
            return try makeCSG(object: object,
                               argumentValues: argumentValues,
                               operation: .difference)
        case .intersection:
            return try makeCSG(object: object,
                               argumentValues: argumentValues,
                               operation: .intersection)
        case .union:
            return try makeCSG(object: object,
                               argumentValues: argumentValues,
                               operation: .union)
        default:
            fatalError("Internal error: only method calls should ever get here")
        }
    }

    private func makeCone(argumentValues: [ScintillaValue]) throws -> ScintillaValue {
        let bottomY = try extractRawDouble(argumentValue: argumentValues[0])
        let topY = try extractRawDouble(argumentValue: argumentValues[1])
        let isCapped = try extractRawBoolean(argumentValue: argumentValues[2])

        let cone = Cone(bottomY: bottomY, topY: topY, isCapped: isCapped)
        return .shape(cone)
    }

    private func makeCylinder(argumentValues: [ScintillaValue]) throws -> ScintillaValue {
        let bottomY = try extractRawDouble(argumentValue: argumentValues[0])
        let topY = try extractRawDouble(argumentValue: argumentValues[1])
        let isCapped = try extractRawBoolean(argumentValue: argumentValues[2])

        let cylinder = Cylinder(bottomY: bottomY, topY: topY, isCapped: isCapped)
        return .shape(cylinder)
    }

    private func makeGroup(argumentValues: [ScintillaValue]) throws -> ScintillaValue {
        let children = try extractRawShapeList(argumentValue: argumentValues[0])

        let group = Group(children: children)
        return .shape(group)
    }

    private func makeImplicitSurface(argumentValues: [ScintillaValue]) throws -> ScintillaValue {
        let bottomFrontLeft = try extractRawTuple3(argumentValue: argumentValues[0])
        let topBackRight = try extractRawTuple3(argumentValue: argumentValues[1])
        let lambda = try extractRawSurfaceFunction(argumentValue: argumentValues[2])

        let implicitSurface = ImplicitSurface(bottomFrontLeft: bottomFrontLeft,
                                              topBackRight: topBackRight,
                                              lambda)
        return .shape(implicitSurface)
    }

    private func makePrism(argumentValues: [ScintillaValue]) throws -> ScintillaValue {
        let bottomY = try extractRawDouble(argumentValue: argumentValues[0])
        let topY = try extractRawDouble(argumentValue: argumentValues[1])
        let xzPoints = try extractRawTuple2List(argumentValue: argumentValues[2])

        let prism = Prism(bottomY: bottomY, topY: topY, xzPoints: xzPoints)
        return .shape(prism)
    }

    private func makeSuperellipsoid(argumentValues: [ScintillaValue]) throws -> ScintillaValue {
        let e = try extractRawDouble(argumentValue: argumentValues[0])
        let n = try extractRawDouble(argumentValue: argumentValues[1])

        let superellipsoid = Superellipsoid(e: e, n: n)
        return .shape(superellipsoid)
    }

    private func makeSurfaceOfRevolution(argumentValues: [ScintillaValue]) throws -> ScintillaValue {
        let yzPoints = try extractRawTuple2List(argumentValue: argumentValues[0])
        let isCapped = try extractRawBoolean(argumentValue: argumentValues[1])

        let sor = SurfaceOfRevolution(yzPoints: yzPoints, isCapped: isCapped)
        return .shape(sor)
    }

    private func makeTorus(argumentValues: [ScintillaValue]) throws -> ScintillaValue {
        let majorRadius = try extractRawDouble(argumentValue: argumentValues[0])
        let minorRadius = try extractRawDouble(argumentValue: argumentValues[1])

        let torus = Torus(majorRadius: majorRadius, minorRadius: minorRadius)
        return .shape(torus)
    }

    private func makeWorld(argumentValues: [ScintillaValue]) throws -> ScintillaValue {
        let camera = try extractRawCamera(argumentValue: argumentValues[0])
        let lights = try extractRawLights(argumentValue: argumentValues[1])
        let shapes = try extractRawShapeList(argumentValue: argumentValues[2])

        let newWorld = World(camera, lights, shapes)
        return .world(newWorld)
    }

    private func makeCamera(argumentValues: [ScintillaValue]) throws -> ScintillaValue {
        let width = try extractRawDouble(argumentValue: argumentValues[0])
        let height = try extractRawDouble(argumentValue: argumentValues[1])
        let viewAngle = try extractRawDouble(argumentValue: argumentValues[2])
        let (fromX, fromY, fromZ) = try extractRawTuple3(argumentValue: argumentValues[3])
        let (toX, toY, toZ) = try extractRawTuple3(argumentValue: argumentValues[4])
        let (upX, upY, upZ) = try extractRawTuple3(argumentValue: argumentValues[5])

        return .camera(Camera(width: Int(width),
                              height: Int(height),
                              viewAngle: viewAngle,
                              from: Point(fromX, fromY, fromZ),
                              to: Point(toX, toY, toZ),
                              up: Vector(upX, upY, upZ)))
    }

    private func makePointLight(argumentValues: [ScintillaValue]) throws -> ScintillaValue {
        let (x, y, z) = try extractRawTuple3(argumentValue: argumentValues[0])

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
        let shape = try extractRawShape(argumentValue: object)
        let (colorComponent0, colorComponent1, colorComponent2) = try extractRawTuple3(argumentValue: argumentValues[0])

        let solidColor: Material = .solidColor(colorComponent0, colorComponent1, colorComponent2, colorSpace)
        return .shape(shape.material(solidColor))
    }

    private func makeTranslate(object: ScintillaValue,
                               argumentValues: [ScintillaValue]) throws -> ScintillaValue {
        let shape = try extractRawShape(argumentValue: object)
        let x = try extractRawDouble(argumentValue: argumentValues[0])
        let y = try extractRawDouble(argumentValue: argumentValues[1])
        let z = try extractRawDouble(argumentValue: argumentValues[2])

        return .shape(shape.translate(x, y, z))
    }

    private func makeScale(object: ScintillaValue,
                           argumentValues: [ScintillaValue]) throws -> ScintillaValue {
        let shape = try extractRawShape(argumentValue: object)
        let x = try extractRawDouble(argumentValue: argumentValues[0])
        let y = try extractRawDouble(argumentValue: argumentValues[1])
        let z = try extractRawDouble(argumentValue: argumentValues[2])

        return .shape(shape.scale(x, y, z))
    }

    private func makeShear(object: ScintillaValue,
                           argumentValues: [ScintillaValue]) throws -> ScintillaValue {
        let shape = try extractRawShape(argumentValue: object)
        let xy = try extractRawDouble(argumentValue: argumentValues[0])
        let xz = try extractRawDouble(argumentValue: argumentValues[1])
        let yx = try extractRawDouble(argumentValue: argumentValues[2])
        let yz = try extractRawDouble(argumentValue: argumentValues[3])
        let zx = try extractRawDouble(argumentValue: argumentValues[4])
        let zy = try extractRawDouble(argumentValue: argumentValues[5])

        return .shape(shape.shear(xy, xz, yx, yz, zx, zy))
    }

    private func makeCSG(object: ScintillaValue,
                         argumentValues: [ScintillaValue],
                         operation: Operation) throws -> ScintillaValue {
        let shape = try extractRawShape(argumentValue: object)
        let rightShapes = try extractRawShapeList(argumentValue: argumentValues[0])

        return .shape(CSG.makeCSG(operation, shape, rightShapes))
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
        let shape = try extractRawShape(argumentValue: object)
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

    private func extractRawBoolean(argumentValue: ScintillaValue) throws -> Bool {
        guard case .boolean(let rawBoolean) = argumentValue else {
            throw RuntimeError.expectedBoolean
        }

        return rawBoolean
    }

    private func extractRawDouble(argumentValue: ScintillaValue) throws -> Double {
        guard case .double(let rawDouble) = argumentValue else {
            throw RuntimeError.expectedDouble
        }

        return rawDouble
    }

    private func extractRawTuple2List(argumentValue: ScintillaValue) throws -> [(Double, Double)] {
        guard case .list(let wrappedTuples) = argumentValue else {
            throw RuntimeError.incorrectArgument
        }

        let rawTupleList = try wrappedTuples.map { wrappedTuple in
            return try extractRawTuple2(argumentValue: wrappedTuple)
        }

        return rawTupleList
    }

    private func extractRawTuple2(argumentValue: ScintillaValue) throws -> (Double, Double) {
        guard case .tuple2(let tuple) = argumentValue else {
            throw RuntimeError.expectedTuple
        }

        guard case (.double(let rawDouble0), .double(let rawDouble1)) = tuple else {
            fatalError("Tuple should only ever have three double values")
        }

        return (rawDouble0, rawDouble1)
    }

    private func extractRawTuple3(argumentValue: ScintillaValue) throws -> (Double, Double, Double) {
        guard case .tuple3(let tuple) = argumentValue else {
            throw RuntimeError.expectedTuple
        }

        guard case (.double(let rawDouble0), .double(let rawDouble1), .double(let rawDouble2)) = tuple else {
            fatalError("Tuple should only ever have three double values")
        }

        return (rawDouble0, rawDouble1, rawDouble2)
    }

    private func extractRawSurfaceFunction(argumentValue: ScintillaValue) throws -> Lambda {
        guard case .lambda(let rawLambda) = argumentValue else {
            throw RuntimeError.expectedLambda
        }

        return rawLambda
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

    private func extractRawShapeList(argumentValue: ScintillaValue) throws -> [any Shape] {
        guard case .list(let wrappedShapes) = argumentValue else {
            throw RuntimeError.incorrectArgument
        }

        let shapes = try wrappedShapes.map { wrappedShape in
            return try extractRawShape(argumentValue: wrappedShape)
        }

        return shapes
    }

    private func extractRawShape(argumentValue: ScintillaValue) throws -> any Shape {
        guard case .shape(let shape) = argumentValue else {
            throw RuntimeError.expectedShape
        }

        return shape
    }
}
