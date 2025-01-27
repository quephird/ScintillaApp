//
//  ScintillaBuiltin.swift
//  ScintillaApp
//
//  Created by Danielle Kefford on 1/26/25.
//

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
        let result: ScintillaValue = switch self {
        case .sphere:
            .double(1)
        case .world:
            .double(2)
        case .camera:
            .double(3)
        case .pointLight:
            .double(4)
        }

        print(result)

        return result
    }
}
