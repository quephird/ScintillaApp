//
//  ScintillaBuiltin.swift
//  ScintillaApp
//
//  Created by Danielle Kefford on 1/26/25.
//

import Darwin
import Foundation

import ScintillaLib

enum ScintillaBuiltin: CaseIterable, Equatable {
    case colorRgb
    case colorHsl
    case cone
    case cube
    case cylinder
    case group
    case implicitSurface1
    case implicitSurface2
    case parametricSurface1
    case parametricSurface2
    case plane
    case prism
    case sphere
    case superellipsoid
    case surfaceOfRevolution
    case torus
    case world
    case camera1
    case camera2
    case pointLight1
    case pointLight2
    case pointLight3
    case pointLight4
    case areaLight1
    case areaLight2
    case areaLight3
    case areaLight4
    case spotLight1
    case spotLight2
    case spotLight3
    case spotLight4
    case uniform
    case striped
    case gradient
    case checkered2D
    case checkered3D
    case colorfunctionRgb
    case colorfunctionHsl
    case marble
    case wood
    case materialMethodCall
    case translateShape
    case translateMaterial
    case scaleShape
    case scaleMaterial
    case rotateXShape
    case rotateXMaterial
    case rotateYShape
    case rotateYMaterial
    case rotateZShape
    case rotateZMaterial
    case shearShape
    case shearMaterial
    case ambient
    case diffuse
    case specular
    case shininess
    case reflective
    case transparency
    case refractive
    case difference
    case intersection
    case union
    case sinFunc
    case cosFunc
    case tanFunc
    case arcsinFunc
    case arccosFunc
    case arctanFunc
    case arctan2Func
    case expFunc
    case logFunc
    case maxFunc
    case minFunc
    case absFunc
    case truncFunc
    case roundFunc
    case each
    case eachWithIndex

    var objectName: ObjectName {
        switch self {
        case .colorRgb:
            return .functionName("Color", ["r", "g", "b"])
        case .colorHsl:
            return .functionName("Color", ["h", "s", "l"])
        case .cone:
            return .functionName("Cone", ["bottomY", "topY", "isCapped"])
        case .cube:
            return .functionName("Cube", [])
        case .cylinder:
            return .functionName("Cylinder", ["bottomY", "topY", "isCapped"])
        case .group:
            return .functionName("Group", [""])
        case .implicitSurface1:
            return .functionName("ImplicitSurface", ["bottomFrontLeft", "topBackRight", "function"])
        case .implicitSurface2:
            return .functionName("ImplicitSurface", ["center", "radius", "function"])
        case .parametricSurface1:
            return .functionName("ParametricSurface", ["bottomFrontLeft", "topBackRight",
                                                       "uRange", "vRange",
                                                       "fx", "fy", "fz"])
        case .parametricSurface2:
            return .functionName("ParametricSurface", ["bottomFrontLeft", "topBackRight",
                                                       "uRange", "vRange",
                                                       "accuracy", "maxGradient",
                                                       "fx", "fy", "fz"])
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
        case .camera1:
            return .functionName("Camera", ["width", "height", "viewAngle", "from", "to", "up"])
        case .camera2:
            return .functionName("Camera", ["width", "height", "viewAngle", "from", "to", "up", "antialiasing"])
        case .pointLight1:
            return .functionName("PointLight", ["position"])
        case .pointLight2:
            return .functionName("PointLight", ["position", "color"])
        case .pointLight3:
            return .functionName("PointLight", ["position", "fadeDistance"])
        case .pointLight4:
            return .functionName("PointLight", ["position", "color", "fadeDistance"])
        case .areaLight1:
            return .functionName("AreaLight", ["corner", "uVector", "uSteps", "vVector", "vSteps"])
        case .areaLight2:
            return .functionName("AreaLight", ["corner", "uVector", "uSteps", "vVector", "vSteps", "color"])
        case .areaLight3:
            return .functionName("AreaLight", ["corner", "uVector", "uSteps", "vVector", "vSteps", "fadeDistance"])
        case .areaLight4:
            return .functionName("AreaLight", ["corner", "uVector", "uSteps", "vVector", "vSteps", "color", "fadeDistance"])
        case .spotLight1:
            return .functionName("SpotLight", ["position", "pointAt", "beamAngle", "falloffAngle", "tightness"])
        case .spotLight2:
            return .functionName("SpotLight", ["position", "pointAt", "beamAngle", "falloffAngle", "tightness", "color"])
        case .spotLight3:
            return .functionName("SpotLight", ["position", "pointAt", "beamAngle", "falloffAngle", "tightness", "fadeDistance"])
        case .spotLight4:
            return .functionName("SpotLight", ["position", "pointAt", "beamAngle", "falloffAngle", "tightness", "color", "fadeDistance"])
        case .uniform:
            return .functionName("Uniform", [""])
        case .striped:
            return .functionName("Striped", ["firstColor", "secondColor"])
        case .gradient:
            return .functionName("Gradient", ["firstColor", "secondColor"])
        case .checkered2D:
            return .functionName("Checkered2D", ["firstColor", "secondColor"])
        case .checkered3D:
            return .functionName("Checkered3D", ["firstColor", "secondColor"])
        case .colorfunctionRgb:
            return .functionName("ColorFunction", ["fr", "fg", "fb"])
        case .colorfunctionHsl:
            return .functionName("ColorFunction", ["fh", "fs", "fl"])
        case .marble:
            return .functionName("Marble", ["firstColor", "secondColor"])
        case .wood:
            return .functionName("Wood", ["firstColor", "secondColor"])
        case .materialMethodCall:
            return .methodName(.shape, "material", [""])
        case .translateShape:
            return .methodName(.shape, "translate", ["x", "y", "z"])
        case .translateMaterial:
            return .methodName(.material, "translate", ["x", "y", "z"])
        case .scaleShape:
            return .methodName(.shape, "scale", ["x", "y", "z"])
        case .scaleMaterial:
            return .methodName(.material, "scale", ["x", "y", "z"])
        case .rotateXShape:
            return .methodName(.shape, "rotateX", [""])
        case .rotateXMaterial:
            return .methodName(.material, "rotateX", [""])
        case .rotateYShape:
            return .methodName(.shape, "rotateY", [""])
        case .rotateYMaterial:
            return .methodName(.material, "rotateY", [""])
        case .rotateZShape:
            return .methodName(.shape, "rotateZ", [""])
        case .rotateZMaterial:
            return .methodName(.material, "rotateZ", [""])
        case .shearShape:
            return .methodName(.shape, "shear", ["xy", "xz", "yx", "yz", "zx", "zy"])
        case .shearMaterial:
            return .methodName(.material, "shear", ["xy", "xz", "yx", "yz", "zx", "zy"])
        case .ambient:
            return .methodName(.material, "ambient", [""])
        case .diffuse:
            return .methodName(.material, "diffuse", [""])
        case .specular:
            return .methodName(.material, "specular", [""])
        case .shininess:
            return .methodName(.material, "shininess", [""])
        case .reflective:
            return .methodName(.material, "reflective", [""])
        case .transparency:
            return .methodName(.material, "transparency", [""])
        case .refractive:
            return .methodName(.material, "refractive", [""])
        case .difference:
            return .methodName(.shape, "difference", [""])
        case .intersection:
            return .methodName(.shape, "intersection", [""])
        case .union:
            return .methodName(.shape, "union", [""])
        case .sinFunc:
            return .functionName("sin", [""])
        case .cosFunc:
            return .functionName("cos", [""])
        case .tanFunc:
            return .functionName("tan", [""])
        case .arcsinFunc:
            return .functionName("arcsin", [""])
        case .arccosFunc:
            return .functionName("arccos", [""])
        case .arctanFunc:
            return .functionName("arctan", [""])
        case .arctan2Func:
            return .functionName("arctan2", ["", ""])
        case .expFunc:
            return .functionName("exp", [""])
        case .logFunc:
            return .functionName("log", [""])
        case .minFunc:
            return .functionName("min", ["", ""])
        case .maxFunc:
            return .functionName("max", ["", ""])
        case .absFunc:
            return .functionName("abs", [""])
        case .truncFunc:
            return .functionName("trunc", [""])
        case .roundFunc:
            return .functionName("round", [""])
        case .each:
            return .methodName(.list, "each", [""])
        case .eachWithIndex:
            return .methodName(.list, "eachWithIndex", [""])
        }
    }

    var isNativeMathematicalFunction: Bool {
        switch self {
        case .sinFunc, .cosFunc, .tanFunc,
                .arcsinFunc, .arccosFunc, .arctanFunc, .arctan2Func,
                .expFunc, .logFunc, .minFunc, .maxFunc, .absFunc, .truncFunc, .roundFunc:
            return true
        default:
            return false
        }
    }

    public func call(_ argValue: Double) -> Double {
        precondition(self.isNativeMathematicalFunction)

        switch self {
        case .sinFunc:
            return sin(argValue)
        case .cosFunc:
            return cos(argValue)
        case .tanFunc:
            return tan(argValue)
        case .arcsinFunc:
            return asin(argValue)
        case .arccosFunc:
            return acos(argValue)
        case .arctanFunc:
            return atan(argValue)
        case .expFunc:
            return exp(argValue)
        case .logFunc:
            return log(argValue)
        case .absFunc:
            return abs(argValue)
        case .truncFunc:
            return trunc(argValue)
        case .roundFunc:
            return round(argValue)
        default:
            fatalError("We should never get here as we already checked if function was a methematical one")
        }
    }

    public func call(_ argValue1: Double, _ argValue2: Double) -> Double {
        precondition(self.isNativeMathematicalFunction)

        switch self {
        case .arctan2Func:
            return atan2(argValue1, argValue2)
        case .minFunc:
            return min(argValue1, argValue2)
        case .maxFunc:
            return max(argValue1, argValue2)
        default:
            fatalError("We should never get here as we already checked if function was a methematical one")
        }
    }

    public func call(evaluator: Evaluator,
                     argumentValues: [ScintillaValue]) throws -> ScintillaValue {
        switch self {
        case .colorRgb:
            return try makeColorRgb(argumentValues: argumentValues)
        case .colorHsl:
            return try makeColorHsl(argumentValues: argumentValues)
        case .cone:
            return try makeCone(argumentValues: argumentValues)
        case .cube:
            return .shape(Cube())
        case .cylinder:
            return try makeCylinder(argumentValues: argumentValues)
        case .group:
            return try makeGroup(argumentValues: argumentValues)
        case .implicitSurface1:
            return try makeImplicitSurface1(evaluator: evaluator, argumentValues: argumentValues)
        case .implicitSurface2:
            return try makeImplicitSurface2(evaluator: evaluator, argumentValues: argumentValues)
        case .parametricSurface1:
            return try makeParametricSurface1(evaluator: evaluator, argumentValues: argumentValues)
        case .parametricSurface2:
            return try makeParametricSurface2(evaluator: evaluator, argumentValues: argumentValues)
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
        case .camera1:
            return try makeCamera(argumentValues: argumentValues)
        case .camera2:
            return try makeCamera(argumentValues: argumentValues)
        case .pointLight1:
            return try makePointLight1(argumentValues: argumentValues)
        case .pointLight2:
            return try makePointLight2(argumentValues: argumentValues)
        case .pointLight3:
            return try makePointLight3(argumentValues: argumentValues)
        case .pointLight4:
            return try makePointLight4(argumentValues: argumentValues)
        case .areaLight1:
            return try makeAreaLight1(argumentValues: argumentValues)
        case .areaLight2:
            return try makeAreaLight2(argumentValues: argumentValues)
        case .areaLight3:
            return try makeAreaLight3(argumentValues: argumentValues)
        case .areaLight4:
            return try makeAreaLight4(argumentValues: argumentValues)
        case .spotLight1:
            return try makeSpotLight1(argumentValues: argumentValues)
        case .spotLight2:
            return try makeSpotLight2(argumentValues: argumentValues)
        case .spotLight3:
            return try makeSpotLight3(argumentValues: argumentValues)
        case .spotLight4:
            return try makeSpotLight4(argumentValues: argumentValues)
        case .uniform:
            return try makeUniform(argumentValues: argumentValues)
        case .gradient, .striped, .checkered2D, .checkered3D, .marble, .wood:
            return try makePattern(argumentValues: argumentValues)
        case .colorfunctionRgb:
            return try makeColorFunctionRgb(evaluator: evaluator, argumentValues: argumentValues)
        case .colorfunctionHsl:
            return try makeColorFunctionHsl(evaluator: evaluator, argumentValues: argumentValues)
        case .world:
            return try makeWorld(argumentValues: argumentValues)
        case .sinFunc, .cosFunc, .tanFunc, .arcsinFunc, .arccosFunc, .arctanFunc, .expFunc, .logFunc, .absFunc:
            return try handleUnaryFunction(argumentValues: argumentValues)
        case .arctan2Func, .maxFunc:
            return try handleBinaryFunction(argumentValues: argumentValues)
        default:
            fatalError("Internal error: method calls should not get here")
        }
    }

    public func callMethod(evaluator: Evaluator,
                           object: ScintillaValue,
                           argumentValues: [ScintillaValue]) throws -> ScintillaValue {
        switch self {
        case .materialMethodCall:
            return try makeMaterialMethodCall(object: object, argumentValues: argumentValues)
        case .translateShape:
            return try makeTranslateShape(object: object, argumentValues: argumentValues)
        case .translateMaterial:
            return try makeTranslateMaterial(object: object, argumentValues: argumentValues)
        case .scaleShape:
            return try makeScaleShape(object: object, argumentValues: argumentValues)
        case .scaleMaterial:
            return try makeScaleMaterial(object: object, argumentValues: argumentValues)
        case .rotateXShape:
            return try makeRotateXShape(object: object, argumentValues: argumentValues)
        case .rotateXMaterial:
            return try makeRotateXMaterial(object: object, argumentValues: argumentValues)
        case .rotateYShape:
            return try makeRotateYShape(object: object, argumentValues: argumentValues)
        case .rotateYMaterial:
            return try makeRotateYMaterial(object: object, argumentValues: argumentValues)
        case .rotateZShape:
            return try makeRotateShape(object: object, argumentValues: argumentValues)
        case .rotateZMaterial:
            return try makeRotateMaterial(object: object, argumentValues: argumentValues)
        case .shearShape:
            return try makeShearShape(object: object, argumentValues: argumentValues)
        case .shearMaterial:
            return try makeShearMaterial(object: object, argumentValues: argumentValues)
        case .ambient:
            return try makeAmbient(object: object, argumentValues: argumentValues)
        case .diffuse:
            return try makeDiffuse(object: object, argumentValues: argumentValues)
        case .specular:
            return try makeSpecular(object: object, argumentValues: argumentValues)
        case .shininess:
            return try makeShininess(object: object, argumentValues: argumentValues)
        case .reflective:
            return try makeReflective(object: object, argumentValues: argumentValues)
        case .transparency:
            return try makeTransparency(object: object, argumentValues: argumentValues)
        case .refractive:
            return try makeRefractive(object: object, argumentValues: argumentValues)
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
        case .each:
            return try handleEach(evaluator: evaluator,
                                  object: object,
                                  argumentValues: argumentValues)
        case .eachWithIndex:
            return try handleEachWithIndex(evaluator: evaluator,
                                           object: object,
                                           argumentValues: argumentValues)
        default:
            fatalError("Internal error: only method calls should ever get here")
        }
    }

    private func makeColorRgb(argumentValues: [ScintillaValue]) throws -> ScintillaValue {
        let r = try extractRawDouble(argumentValue: argumentValues[0])
        let g = try extractRawDouble(argumentValue: argumentValues[1])
        let b = try extractRawDouble(argumentValue: argumentValues[2])

        let color = Color(r, g, b)
        return .color(color)
    }

    private func makeColorHsl(argumentValues: [ScintillaValue]) throws -> ScintillaValue {
        let h = try extractRawDouble(argumentValue: argumentValues[0])
        let s = try extractRawDouble(argumentValue: argumentValues[1])
        let l = try extractRawDouble(argumentValue: argumentValues[2])

        let color = Color.fromHsl(h, s, l)
        return .color(color)
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

    private func makeImplicitSurface1(evaluator: Evaluator,
                                      argumentValues: [ScintillaValue]) throws -> ScintillaValue {
        let bottomFrontLeft = try extractRawTuple3(argumentValue: argumentValues[0])
        let topBackRight = try extractRawTuple3(argumentValue: argumentValues[1])
        let lambda = try extractRawImplicitSurfaceFunction(evaluator: evaluator,
                                                           argumentValue: argumentValues[2])

        let implicitSurface = ImplicitSurface(bottomFrontLeft: bottomFrontLeft,
                                              topBackRight: topBackRight,
                                              lambda)
        return .shape(implicitSurface)
    }

    private func makeImplicitSurface2(evaluator: Evaluator,
                                      argumentValues: [ScintillaValue]) throws -> ScintillaValue {
        let center = try extractRawTuple3(argumentValue: argumentValues[0])
        let radius = try extractRawDouble(argumentValue: argumentValues[1])
        let lambda = try extractRawImplicitSurfaceFunction(evaluator: evaluator,
                                                           argumentValue: argumentValues[2])

        let implicitSurface = ImplicitSurface(center: center,
                                              radius: radius,
                                              lambda)
        return .shape(implicitSurface)
    }

    private func makeParametricSurface1(evaluator: Evaluator,
                                        argumentValues: [ScintillaValue]) throws -> ScintillaValue {
        let bottomFrontLeft = try extractRawTuple3(argumentValue: argumentValues[0])
        let topBackRight = try extractRawTuple3(argumentValue: argumentValues[1])
        let uRange = try extractRawTuple2(argumentValue: argumentValues[2])
        let vRange = try extractRawTuple2(argumentValue: argumentValues[3])
        let fx = try extractRawParametricSurfaceFunction(evaluator: evaluator,
                                                         argumentValue: argumentValues[4])
        let fy = try extractRawParametricSurfaceFunction(evaluator: evaluator,
                                                         argumentValue: argumentValues[5])
        let fz = try extractRawParametricSurfaceFunction(evaluator: evaluator,
                                                         argumentValue: argumentValues[6])

        let parametricSurface = ParametricSurface(bottomFrontLeft: bottomFrontLeft,
                                                  topBackRight: topBackRight,
                                                  uRange: uRange,
                                                  vRange: vRange,
                                                  fx: fx, fy: fy, fz: fz)
        return .shape(parametricSurface)
    }

    private func makeParametricSurface2(evaluator: Evaluator,
                                        argumentValues: [ScintillaValue]) throws -> ScintillaValue {
        let bottomFrontLeft = try extractRawTuple3(argumentValue: argumentValues[0])
        let topBackRight = try extractRawTuple3(argumentValue: argumentValues[1])
        let uRange = try extractRawTuple2(argumentValue: argumentValues[2])
        let vRange = try extractRawTuple2(argumentValue: argumentValues[3])
        let accuracy = try extractRawDouble(argumentValue: argumentValues[4])
        let maxGradient = try extractRawDouble(argumentValue: argumentValues[5])
        let fx = try extractRawParametricSurfaceFunction(evaluator: evaluator,
                                                         argumentValue: argumentValues[6])
        let fy = try extractRawParametricSurfaceFunction(evaluator: evaluator,
                                                         argumentValue: argumentValues[7])
        let fz = try extractRawParametricSurfaceFunction(evaluator: evaluator,
                                                         argumentValue: argumentValues[8])

        let parametricSurface = ParametricSurface(bottomFrontLeft: bottomFrontLeft,
                                                  topBackRight: topBackRight,
                                                  uRange: uRange,
                                                  vRange: vRange,
                                                  accuracy: accuracy,
                                                  maxGradient: maxGradient,
                                                  fx: fx, fy: fy, fz: fz)
        return .shape(parametricSurface)
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
        var antialiasing = false
        if argumentValues.count > 6 {
            antialiasing = try extractRawBoolean(argumentValue: argumentValues[6])
        }

        return .camera(Camera(width: Int(width),
                              height: Int(height),
                              viewAngle: viewAngle,
                              from: Point(fromX, fromY, fromZ),
                              to: Point(toX, toY, toZ),
                              up: Vector(upX, upY, upZ),
                              antialiasing: antialiasing))
    }

    private func makePointLight1(argumentValues: [ScintillaValue]) throws -> ScintillaValue {
        let (x, y, z) = try extractRawTuple3(argumentValue: argumentValues[0])

        let point = Point(x, y, z)
        return .light(PointLight(position: point))
    }

    private func makePointLight2(argumentValues: [ScintillaValue]) throws -> ScintillaValue {
        let (x, y, z) = try extractRawTuple3(argumentValue: argumentValues[0])
        let point = Point(x, y, z)
        let color = try extractRawColor(argumentValue: argumentValues[1])

        return .light(PointLight(position: point, color: color))
    }

    private func makePointLight3(argumentValues: [ScintillaValue]) throws -> ScintillaValue {
        let (x, y, z) = try extractRawTuple3(argumentValue: argumentValues[0])
        let point = Point(x, y, z)
        let fadeDistance = try extractRawDouble(argumentValue: argumentValues[1])

        return .light(PointLight(position: point, fadeDistance: fadeDistance))
    }

    private func makePointLight4(argumentValues: [ScintillaValue]) throws -> ScintillaValue {
        let (x, y, z) = try extractRawTuple3(argumentValue: argumentValues[0])
        let point = Point(x, y, z)
        let color = try extractRawColor(argumentValue: argumentValues[1])
        let fadeDistance = try extractRawDouble(argumentValue: argumentValues[2])

        let light = PointLight(position: point, color: color, fadeDistance: fadeDistance)
        return .light(light)
    }

    private func makeAreaLight1(argumentValues: [ScintillaValue]) throws -> ScintillaValue {
        return try makeAreaLight(argumentValues: argumentValues)
    }

    private func makeAreaLight2(argumentValues: [ScintillaValue]) throws -> ScintillaValue {
        let color = try extractRawColor(argumentValue: argumentValues[5])
        return try makeAreaLight(argumentValues: argumentValues, color: color)
    }

    private func makeAreaLight3(argumentValues: [ScintillaValue]) throws -> ScintillaValue {
        let fadeDistance = try extractRawDouble(argumentValue: argumentValues[5])
        return try makeAreaLight(argumentValues: argumentValues, fadeDistance: fadeDistance)
    }

    private func makeAreaLight4(argumentValues: [ScintillaValue]) throws -> ScintillaValue {
        let color = try extractRawColor(argumentValue: argumentValues[5])
        let fadeDistance = try extractRawDouble(argumentValue: argumentValues[6])
        return try makeAreaLight(argumentValues: argumentValues,
                                 color: color,
                                 fadeDistance: fadeDistance)
    }

    private func makeAreaLight(argumentValues: [ScintillaValue],
                               color: Color = .white,
                               fadeDistance: Double? = nil) throws -> ScintillaValue {
        let (cornerX, cornerY, cornerZ) = try extractRawTuple3(argumentValue: argumentValues[0])
        let corner = Point(cornerX, cornerY, cornerZ)
        let (uVectorX, uVectorY, uVectorZ) = try extractRawTuple3(argumentValue: argumentValues[1])
        let uVector = Vector(uVectorX, uVectorY, uVectorZ)
        let uSteps = Int(try extractRawDouble(argumentValue: argumentValues[2]))
        let (vVectorX, vVectorY, vVectorZ) = try extractRawTuple3(argumentValue: argumentValues[3])
        let vVector = Vector(vVectorX, vVectorY, vVectorZ)
        let vSteps = Int(try extractRawDouble(argumentValue: argumentValues[4]))

        let light = AreaLight(
            corner: corner,
            color: color,
            uVec: uVector,
            uSteps: uSteps,
            vVec: vVector,
            vSteps: vSteps,
            fadeDistance: fadeDistance)
        return .light(light)
    }

    private func makeSpotLight1(argumentValues: [ScintillaValue]) throws -> ScintillaValue {
        return try makeSpotLight(argumentValues: argumentValues)
    }

    private func makeSpotLight2(argumentValues: [ScintillaValue]) throws -> ScintillaValue {
        let color = try extractRawColor(argumentValue: argumentValues[5])
        return try makeSpotLight(argumentValues: argumentValues, color: color)
    }

    private func makeSpotLight3(argumentValues: [ScintillaValue]) throws -> ScintillaValue {
        let fadeDistance = try extractRawDouble(argumentValue: argumentValues[5])
        return try makeSpotLight(argumentValues: argumentValues, fadeDistance: fadeDistance)
    }

    private func makeSpotLight4(argumentValues: [ScintillaValue]) throws -> ScintillaValue {
        let color = try extractRawColor(argumentValue: argumentValues[5])
        let fadeDistance = try extractRawDouble(argumentValue: argumentValues[6])
        return try makeSpotLight(argumentValues: argumentValues,
                                 color: color,
                                 fadeDistance: fadeDistance)
    }

    private func makeSpotLight(argumentValues: [ScintillaValue],
                               color: Color = .white,
                               fadeDistance: Double? = nil) throws -> ScintillaValue {
        let (positionX, positionY, positionZ) = try extractRawTuple3(argumentValue: argumentValues[0])
        let position = Point(positionX, positionY, positionZ)
        let (pointAtX, pointAtY, pointAtZ) = try extractRawTuple3(argumentValue: argumentValues[1])
        let pointAt = Point(pointAtX, pointAtY, pointAtZ)
        let beamAngle = try extractRawDouble(argumentValue: argumentValues[2])
        let falloffAngle = try extractRawDouble(argumentValue: argumentValues[3])
        let tightness = try extractRawDouble(argumentValue: argumentValues[4])

        let light = SpotLight(
            position: position,
            pointAt: pointAt,
            beamAngle: beamAngle,
            falloffAngle: falloffAngle,
            tightness: tightness,
            color: color,
            fadeDistance: fadeDistance)
        return .light(light)
    }


    private func makeUniform(argumentValues: [ScintillaValue]) throws -> ScintillaValue {
        let color = try extractRawColor(argumentValue: argumentValues[0])
        let uniform: Material = .uniform(color)
        return .material(uniform)
    }

    private func makePattern(argumentValues: [ScintillaValue]) throws -> ScintillaValue {
        let firstColor = try extractRawColor(argumentValue: argumentValues[0])
        let secondColor = try extractRawColor(argumentValue: argumentValues[1])

        var pattern: Pattern
        switch self {
        case .gradient:
            pattern = Gradient(firstColor, secondColor, .identity)
        case .striped:
            pattern = Striped(firstColor, secondColor, .identity)
        case .checkered2D:
            pattern = Checkered2D(firstColor, secondColor, .identity)
        case .checkered3D:
            pattern = Checkered3D(firstColor, secondColor, .identity)
        case .marble:
            pattern = Marble(firstColor, secondColor, .identity)
        case .wood:
            pattern = Wood(firstColor, secondColor, .identity)
        default:
            fatalError("Unable to make a pattern object: \(self)")
        }
        return .material(pattern)
    }

    private func makeColorFunctionRgb(evaluator: Evaluator,
                                      argumentValues: [ScintillaValue]) throws -> ScintillaValue {
        let fr = try extractRawImplicitSurfaceFunction(evaluator: evaluator,
                                                       argumentValue: argumentValues[0])
        let fg = try extractRawImplicitSurfaceFunction(evaluator: evaluator,
                                                       argumentValue: argumentValues[0])
        let fb = try extractRawImplicitSurfaceFunction(evaluator: evaluator,
                                                       argumentValue: argumentValues[0])

        let colorFunction = { x, y, z in (fr(x, y, z), fg(x, y, z), fb(x, y, z))}
        let colorFunctionRgb = ColorFunction(.rgb, colorFunction)
        return .material(colorFunctionRgb)
    }

    private func makeColorFunctionHsl(evaluator: Evaluator,
                                      argumentValues: [ScintillaValue]) throws -> ScintillaValue {
        let fh = try extractRawImplicitSurfaceFunction(evaluator: evaluator,
                                                       argumentValue: argumentValues[0])
        let fs = try extractRawImplicitSurfaceFunction(evaluator: evaluator,
                                                       argumentValue: argumentValues[1])
        let fl = try extractRawImplicitSurfaceFunction(evaluator: evaluator,
                                                       argumentValue: argumentValues[2])

        let colorFunction = { x, y, z in (fh(x, y, z), fs(x, y, z), fl(x, y, z))}
        let colorFunctionHsl = ColorFunction(.hsl, colorFunction)
        return .material(colorFunctionHsl)
    }

    private func makeMaterialMethodCall(object: ScintillaValue,
                                        argumentValues: [ScintillaValue]) throws -> ScintillaValue {
        let shape = try extractRawShape(argumentValue: object)
        let material = try extractRawMaterial(argumentValue: argumentValues[0])

        return .shape(shape.material(material))
    }

    private func makeTranslateShape(object: ScintillaValue,
                                    argumentValues: [ScintillaValue]) throws -> ScintillaValue {
        let shape = try extractRawShape(argumentValue: object)
        let x = try extractRawDouble(argumentValue: argumentValues[0])
        let y = try extractRawDouble(argumentValue: argumentValues[1])
        let z = try extractRawDouble(argumentValue: argumentValues[2])

        return .shape(shape.translate(x, y, z))
    }

    private func makeTranslateMaterial(object: ScintillaValue,
                                       argumentValues: [ScintillaValue]) throws -> ScintillaValue {
        let material = try extractRawMaterial(argumentValue: object)
        let x = try extractRawDouble(argumentValue: argumentValues[0])
        let y = try extractRawDouble(argumentValue: argumentValues[1])
        let z = try extractRawDouble(argumentValue: argumentValues[2])

        return .material(material.translate(x, y, z))
    }

    private func makeScaleShape(object: ScintillaValue,
                                argumentValues: [ScintillaValue]) throws -> ScintillaValue {
        let shape = try extractRawShape(argumentValue: object)
        let x = try extractRawDouble(argumentValue: argumentValues[0])
        let y = try extractRawDouble(argumentValue: argumentValues[1])
        let z = try extractRawDouble(argumentValue: argumentValues[2])

        return .shape(shape.scale(x, y, z))
    }

    private func makeScaleMaterial(object: ScintillaValue,
                                   argumentValues: [ScintillaValue]) throws -> ScintillaValue {
        let material = try extractRawMaterial(argumentValue: object)
        let x = try extractRawDouble(argumentValue: argumentValues[0])
        let y = try extractRawDouble(argumentValue: argumentValues[1])
        let z = try extractRawDouble(argumentValue: argumentValues[2])

        return .material(material.scale(x, y, z))
    }

    private func makeShearShape(object: ScintillaValue,
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

    private func makeShearMaterial(object: ScintillaValue,
                                   argumentValues: [ScintillaValue]) throws -> ScintillaValue {
        let material = try extractRawMaterial(argumentValue: object)
        let xy = try extractRawDouble(argumentValue: argumentValues[0])
        let xz = try extractRawDouble(argumentValue: argumentValues[1])
        let yx = try extractRawDouble(argumentValue: argumentValues[2])
        let yz = try extractRawDouble(argumentValue: argumentValues[3])
        let zx = try extractRawDouble(argumentValue: argumentValues[4])
        let zy = try extractRawDouble(argumentValue: argumentValues[5])

        return .material(material.shear(xy, xz, yx, yz, zx, zy))
    }

    private func makeCSG(object: ScintillaValue,
                         argumentValues: [ScintillaValue],
                         operation: ScintillaLib.Operation) throws -> ScintillaValue {
        let shape = try extractRawShape(argumentValue: object)
        let rightShapes = try extractRawShapeList(argumentValue: argumentValues[0])

        return .shape(CSG.makeCSG(operation, shape, rightShapes))
    }

    private enum RotationAxis {
        case x, y, z
    }

    private func makeRotateXShape(object: ScintillaValue,
                                  argumentValues: [ScintillaValue]) throws -> ScintillaValue {
        return try makeRotationShapeCall(object: object,
                                         argumentValues: argumentValues,
                                         rotationAxis: .x)
    }

    private func makeRotateYShape(object: ScintillaValue,
                                  argumentValues: [ScintillaValue]) throws -> ScintillaValue {
        return try makeRotationShapeCall(object: object,
                                         argumentValues: argumentValues,
                                         rotationAxis: .y)
    }

    private func makeRotateShape(object: ScintillaValue,
                                 argumentValues: [ScintillaValue]) throws -> ScintillaValue {
        return try makeRotationShapeCall(object: object,
                                         argumentValues: argumentValues,
                                         rotationAxis: .z)
    }

    private func makeRotationShapeCall(object: ScintillaValue,
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

    private func makeRotateXMaterial(object: ScintillaValue,
                                     argumentValues: [ScintillaValue]) throws -> ScintillaValue {
        return try makeRotationMaterialCall(object: object,
                                            argumentValues: argumentValues,
                                            rotationAxis: .x)
    }

    private func makeRotateYMaterial(object: ScintillaValue,
                                     argumentValues: [ScintillaValue]) throws -> ScintillaValue {
        return try makeRotationMaterialCall(object: object,
                                            argumentValues: argumentValues,
                                            rotationAxis: .y)
    }

    private func makeRotateMaterial(object: ScintillaValue,
                                    argumentValues: [ScintillaValue]) throws -> ScintillaValue {
        return try makeRotationMaterialCall(object: object,
                                            argumentValues: argumentValues,
                                            rotationAxis: .z)
    }

    private func makeRotationMaterialCall(object: ScintillaValue,
                                          argumentValues: [ScintillaValue],
                                          rotationAxis: RotationAxis) throws -> ScintillaValue {
        let material = try extractRawMaterial(argumentValue: object)
        let theta = try extractRawDouble(argumentValue: argumentValues[0])

        return switch rotationAxis {
        case .x:
            .material(material.rotateX(theta))
        case .y:
            .material(material.rotateY(theta))
        case .z:
            .material(material.rotateZ(theta))
        }
    }

    private func makeAmbient(object: ScintillaValue,
                             argumentValues: [ScintillaValue]) throws -> ScintillaValue {
        let material = try extractRawMaterial(argumentValue: object)
        let n = try extractRawDouble(argumentValue: argumentValues[0])

        return .material(material.ambient(n))
    }

    private func makeDiffuse(object: ScintillaValue,
                             argumentValues: [ScintillaValue]) throws -> ScintillaValue {
        let material = try extractRawMaterial(argumentValue: object)
        let n = try extractRawDouble(argumentValue: argumentValues[0])

        return .material(material.diffuse(n))
    }


    private func makeSpecular(object: ScintillaValue,
                              argumentValues: [ScintillaValue]) throws -> ScintillaValue {
        let material = try extractRawMaterial(argumentValue: object)
        let n = try extractRawDouble(argumentValue: argumentValues[0])

        return .material(material.specular(n))
    }


    private func makeShininess(object: ScintillaValue,
                               argumentValues: [ScintillaValue]) throws -> ScintillaValue {
        let material = try extractRawMaterial(argumentValue: object)
        let n = try extractRawDouble(argumentValue: argumentValues[0])

        return .material(material.shininess(n))
    }


    private func makeReflective(object: ScintillaValue,
                                argumentValues: [ScintillaValue]) throws -> ScintillaValue {
        let material = try extractRawMaterial(argumentValue: object)
        let n = try extractRawDouble(argumentValue: argumentValues[0])

        return .material(material.reflective(n))
    }

    private func makeTransparency(object: ScintillaValue,
                                  argumentValues: [ScintillaValue]) throws -> ScintillaValue {
        let material = try extractRawMaterial(argumentValue: object)
        let n = try extractRawDouble(argumentValue: argumentValues[0])

        return .material(material.transparency(n))
    }

    private func makeRefractive(object: ScintillaValue,
                                argumentValues: [ScintillaValue]) throws -> ScintillaValue {
        let material = try extractRawMaterial(argumentValue: object)
        let n = try extractRawDouble(argumentValue: argumentValues[0])

        return .material(material.refractive(n))
    }

    private func handleEach(evaluator: Evaluator,
                            object: ScintillaValue,
                            argumentValues: [ScintillaValue]) throws -> ScintillaValue {
        guard case .list(let elements) = object else {
            throw RuntimeError.incorrectObject
        }

        guard case .lambda(let lambda) = argumentValues[0] else {
            throw RuntimeError.expectedLambda
        }

        guard lambda.argumentNames.count == 1 else {
            throw RuntimeError.closureHasWrongArity(1, lambda.argumentNames.count)
        }

        let results: [ScintillaValue] = try elements.map { element in
            let argumentValues: [ScintillaValue] = [element]
            return try lambda.call(evaluator: evaluator, argumentValues: argumentValues)
        }

        return .list(results)
    }

    private func handleEachWithIndex(evaluator: Evaluator,
                                     object: ScintillaValue,
                                     argumentValues: [ScintillaValue]) throws -> ScintillaValue {
        guard case .list(let elements) = object else {
            throw RuntimeError.incorrectObject
        }

        guard case .lambda(let lambda) = argumentValues[0] else {
            throw RuntimeError.expectedLambda
        }

        guard lambda.argumentNames.count == 2 else {
            throw RuntimeError.closureHasWrongArity(2, lambda.argumentNames.count)
        }

        let results: [ScintillaValue] = try elements.enumerated().map { index, element in
            let argumentValues: [ScintillaValue] = [.double(Double(index)), element]
            return try lambda.call(evaluator: evaluator, argumentValues: argumentValues)
        }

        return .list(results)
    }

    private func handleUnaryFunction(argumentValues: [ScintillaValue]) throws -> ScintillaValue {
        let rawArgumentValue = try extractRawDouble(argumentValue: argumentValues[0])

        return .double(self.call(rawArgumentValue))
    }

    private func handleBinaryFunction(argumentValues: [ScintillaValue]) throws -> ScintillaValue {
        let rawY = try extractRawDouble(argumentValue: argumentValues[0])
        let rawX = try extractRawDouble(argumentValue: argumentValues[1])

        switch self {
        case .arctan2Func:
            return .double(atan2(rawY, rawX))
        case .maxFunc:
            return .double(max(rawY, rawX))
        default:
            fatalError("Unable to handle binary function, \(self)")
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

    private func extractRawColor(argumentValue: ScintillaValue) throws -> Color {
        guard case .color(let color) = argumentValue else {
            throw RuntimeError.expectedColor
        }

        return color
    }

    private func extractRawMaterial(argumentValue: ScintillaValue) throws -> any Material {
        guard case .material(let material) = argumentValue else {
            throw RuntimeError.expectedMaterial
        }

        return material
    }

    private func extractRawShape(argumentValue: ScintillaValue) throws -> any Shape {
        guard case .shape(let shape) = argumentValue else {
            throw RuntimeError.expectedShape
        }

        return shape
    }

    private func extractRawImplicitSurfaceFunction(evaluator: Evaluator,
                                                   argumentValue: ScintillaValue) throws -> ImplicitSurfaceLambda {
        guard case .lambda(let udf) = argumentValue else {
            throw RuntimeError.expectedUserDefinedFunction
        }

        guard udf.argumentNames.count == 3 else {
            throw RuntimeError.implicitSurfaceLambdaWrongArity
        }

        return try makeRawLambda(evaluator: evaluator,
                                 expression: udf.returnExpr)
    }

    private func extractRawParametricSurfaceFunction(evaluator: Evaluator,
                                                     argumentValue: ScintillaValue) throws -> ParametricSurfaceLambda {
        guard case .lambda(let udf) = argumentValue else {
            throw RuntimeError.expectedUserDefinedFunction
        }

        guard udf.argumentNames.count == 2 else {
            throw RuntimeError.parametricSurfaceLambdaWrongArity
        }

        let innerLambda = try makeRawLambda(evaluator: evaluator, expression: udf.returnExpr)
        return { x, y in innerLambda(x, y, 0) }
    }

    private func makeRawLambda(evaluator: Evaluator,
                               expression: Expression<ResolvedLocation>) throws -> ImplicitSurfaceLambda {
        switch expression {
        case .doubleLiteral(_, let rawDouble):
            return { _, _, _ in rawDouble }
        case .variable(let nameToken, let location):
            switch (location.depth, location.index) {
            case (0, 0):
                return { x, _, _ in return x }
            case (0, 1):
                return { _, y, _ in return y }
            case (0, 2):
                return { _, _, z in return z }
            default:
                var copy = location
                copy.depth -= 1
                let foo = try evaluator.environment.getValueAtLocation(location: copy)
                if case .double(let value) = foo {
                    return { _, _, _ in return value }
                }
            }

            throw RuntimeError.couldNotEvaluateVariable(nameToken)
        case .unary(let operToken, let expr):
            let lambda = try makeRawLambda(evaluator: evaluator, expression: expr)

            switch operToken.type {
            case .minus:
                return { x, y, z in -lambda(x, y, z) }
            default:
                throw RuntimeError.unsupportedUnaryOperator(operToken.location, operToken.lexeme)
            }
        case .binary(let leftExpr, let operToken, let rightExpr):
            let leftLambda = try makeRawLambda(evaluator: evaluator, expression: leftExpr)
            let rightLambda = try makeRawLambda(evaluator: evaluator, expression: rightExpr)

            switch operToken.type {
            case .plus:
                return { x, y, z in leftLambda(x, y, z) + rightLambda(x, y, z) }
            case .minus:
                return { x, y, z in leftLambda(x, y, z) - rightLambda(x, y, z) }
            case .star:
                return { x, y, z in leftLambda(x, y, z) * rightLambda(x, y, z) }
            case .slash:
                return { x, y, z in leftLambda(x, y, z) / rightLambda(x, y, z) }
            case .caret:
                return { x, y, z in
                    let leftValue = leftLambda(x, y, z)
                    let rightValue = rightLambda(x, y, z)
                    return pow(leftValue, rightValue) }
            default:
                throw RuntimeError.unsupportedBinaryOperator(operToken.location, operToken.lexeme)
            }
        case .call(let calleeExpr, _, let localArguments):
            guard case .function(_, _, let location) = calleeExpr else {
                throw RuntimeError.notAFunction(calleeExpr.locationToken.location, calleeExpr.locationToken.lexeme)
            }

            let firstArgValue = try makeRawLambda(evaluator: evaluator,
                                                  expression: localArguments[0].value)

            var copy = location
            copy.depth -= 1
            let lookedUpFunction = try evaluator.environment.getValueAtLocation(location: copy)

            switch lookedUpFunction {
            case .builtin(let builtin):
                if builtin.isNativeMathematicalFunction {
                    if localArguments.count == 2 {
                        let secondArgValue = try makeRawLambda(evaluator: evaluator,
                                                               expression: localArguments[1].value)
                        return { x, y, z in
                            return builtin.call(firstArgValue(x, y, z), secondArgValue(x, y, z))
                        }
                    }

                    return { x, y, z in return builtin.call(firstArgValue(x, y, z)) }
                }

                throw RuntimeError.notAPureMathFunction(builtin.objectName)
            case .userDefinedFunction(let udf):
                var secondArgValue: ImplicitSurfaceLambda = { _, _, _ in 0.0 }
                var thirdArgValue: ImplicitSurfaceLambda = { _, _, _ in 0.0 }
                if localArguments.count == 3 {
                    thirdArgValue = try makeRawLambda(evaluator: evaluator,
                                                      expression: localArguments[2].value)
                }

                if localArguments.count >= 2 {
                    secondArgValue = try makeRawLambda(evaluator: evaluator,
                                                       expression: localArguments[1].value)
                }

                return { (x: Double, y: Double, z: Double) -> Double in
                    // TODO: Figure out how to surface either of these errors _without_ throwing
                    let result: Double
                    do {
                        result = try udf.call(evaluator: evaluator,
                                              argumentValues: firstArgValue(x, y, z),
                                              secondArgValue(x, y, z),
                                              thirdArgValue(x, y, z))
                    } catch {
                        fatalError("Something bad happened during the execution of the lambda")
                    }

                    return result
                }
            default:
                throw RuntimeError.couldNotEvaluateFunction(calleeExpr.locationToken)
            }
        default:
            throw RuntimeError.couldNotConstructLambda(expression.locationToken)
        }
    }
}
