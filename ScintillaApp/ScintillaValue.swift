//
//  ScintillaValue.swift
//  ScintillaApp
//
//  Created by Danielle Kefford on 1/23/25.
//

import ScintillaLib

import Foundation

enum ScintillaValue: Equatable, CustomStringConvertible {
    case boolean(Bool)
    case double(Double)
    case list([ScintillaValue])
    indirect case tuple2((ScintillaValue, ScintillaValue))
    indirect case tuple3((ScintillaValue, ScintillaValue, ScintillaValue))
    case function(ScintillaBuiltin)
    indirect case boundMethod(ScintillaValue, ScintillaBuiltin)
    case lambda(Lambda, UUID)
    case userDefinedFunction(UserDefinedFunction)
    case shape(any Shape)
    case camera(Camera)
    case light(Light)
    case world(World)

    var type: ScintillaType {
        switch self {
        case .boolean:
            return .boolean
        case .double:
            return .double
        case .list:
            return .list
        case .tuple2:
            return .tuple2
        case .tuple3:
            return .tuple3
        case .function:
            return .function
        case .boundMethod:
            return .boundMethod
        case .lambda:
            return .lambda
        case .userDefinedFunction:
            return .userDefinedFunction
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
        case (.boolean(let l), .boolean(let r)):
            return l == r
        case (.double(let l), .double(let r)):
            return l == r
        case (.list(let l), .list(let r)):
            return l == r
        case (.tuple2(let l), .tuple2(let r)):
            return l == r
        case (.tuple3(let l), .tuple3(let r)):
            return l == r
        case (.function(let l), .function(let r)):
            return l == r
        case (.boundMethod(let l1, let l2), .boundMethod(let r1, let r2)):
            return l1 == r1 && l2 == r2
        case (.lambda(_, let leftId), .lambda(_, let rightId)):
            return leftId == rightId
        case (.userDefinedFunction(let l), .userDefinedFunction(let r)):
            return l.objectId == r.objectId
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
        case .boolean(let value):
            return "\(value)"
        case .double(let value):
            return "\(value)"
        case .list(let values):
            return values.map { "\($0)" }.joined(separator: ", ")
        case .tuple2(let values):
            return "(\(values.0), \(values.1))"
        case .tuple3(let values):
            return "(\(values.0), \(values.1), \(values.2))"
        case .function(let builtin):
            return "\(builtin.objectName)"
        case .boundMethod(_, let builtin):
            return "\(builtin.objectName)"
        case .lambda(let lambda, _):
            return "<lambda>"
        case .userDefinedFunction(let userDefinedFunction):
            return "<function: \(userDefinedFunction.name)>"
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

    var isCallable: Bool {
        switch self {
        case .function, .boundMethod, .lambda, .userDefinedFunction:
            return true
        default:
            return false
        }
    }
}
