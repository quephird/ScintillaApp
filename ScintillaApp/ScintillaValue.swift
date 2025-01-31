//
//  ScintillaValue.swift
//  ScintillaApp
//
//  Created by Danielle Kefford on 1/23/25.
//

import ScintillaLib

enum ScintillaValue: Equatable, CustomStringConvertible {
    case double(Double)
    case list([ScintillaValue])
    indirect case tuple((ScintillaValue, ScintillaValue, ScintillaValue))
    case function(ScintillaBuiltin)
    case shape(any Shape)
    case camera(Camera)
    case light(Light)
    case world(World)

    var type: ScintillaType {
        switch self {
        case .double:
            return .double
        case .list:
            return .list
        case .tuple:
            return .tuple
        case .function:
            return .function
        case .shape(_):
            return .shape
        case .camera(_):
            return .camera
        case .light(_):
            return .light
        case .world(_):
            return .world
        }
    }

    static func == (lhs: ScintillaValue, rhs: ScintillaValue) -> Bool {
        switch (lhs, rhs) {
        case (.double(let l), .double(let r)):
            return l == r
        case (.list(let l), .list(let r)):
            return l == r
        case (.tuple(let l), .tuple(let r)):
            return l == r
        case (.function(let l), .function(let r)):
            return l == r
        case (.shape(let l), .shape(let r)):
            return l == r
        case (.camera(let l), .camera(let r)):
            return l == r
        case (.light(let l), .light(let r)):
            // TODO: Move this into a standalone function in ScintillaLib
            if let l = l as? PointLight, let r = r as? PointLight {
                return l == r
            } else if let l = l as? AreaLight, let r = r as? AreaLight {
                return l == r
            } else {
                return false
            }
        case (.world(let l), .world(let r)):
            return l === r
        default:
            return false
        }
    }

    var description: String {
        switch self {
        case .double(let value):
            return "\(value)"
        case .list(let values):
            return values.map { "\($0)" }.joined(separator: ", ")
        case .tuple(let values):
            return "(\(values.0), \(values.1), \(values.2))"
        case .function(let builtin):
            return "\(builtin.objectName)"
        case .shape(let shape):
            return "\(shape)"
        case .camera(let camera):
            return "\(camera)"
        case .light(let light):
            return "\(light)"
        case .world(let world):
            return "\(world)"
        }
    }
}
