//
//  ScintillaValue.swift
//  ScintillaApp
//
//  Created by Danielle Kefford on 1/23/25.
//

import ScintillaLib

import Foundation

typealias ImplicitSurfaceLambda = (Double, Double, Double) -> Double
typealias ParametricSurfaceLambda = (Double, Double) -> Double

enum ScintillaValue: Equatable, CustomStringConvertible {
    case boolean(Bool)
    case double(Double)
    indirect case list([ScintillaValue])
    indirect case tuple2((ScintillaValue, ScintillaValue))
    indirect case tuple3((ScintillaValue, ScintillaValue, ScintillaValue))
    case builtin(ScintillaBuiltin)
    indirect case boundMethod(ScintillaValue, ScintillaBuiltin)
    indirect case lambda(UserDefinedFunction)
    indirect case userDefinedFunction(UserDefinedFunction)
    case color(Color)
    case material(Material)
    indirect case shape(any Shape)
    indirect case camera(Camera)
    indirect case light(Light)
    indirect case world(World)

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
        case .builtin:
            return .builtin
        case .boundMethod:
            return .boundMethod
        case .lambda:
            return .lambda
        case .userDefinedFunction:
            return .userDefinedFunction
        case .color:
            return .color
        case .material(_):
            return .material
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
        case (.builtin(let l), .builtin(let r)):
            return l == r
        case (.boundMethod(let l1, let l2), .boundMethod(let r1, let r2)):
            return l1 == r1 && l2 == r2
        case (.lambda(let l), .lambda(let r)):
            return l.objectId == r.objectId
        case (.userDefinedFunction(let l), .userDefinedFunction(let r)):
            return l.objectId == r.objectId
        case (.color(let l), .color(let r)):
            return l == r
        case (.material(let l), .material(let r)):
            // TODO: Return to this and actually implement this!
            return true
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
        case .builtin(let builtin):
            return "\(builtin.objectName)"
        case .boundMethod(_, let builtin):
            return "\(builtin.objectName)"
        case .lambda(let userDefinedFunction):
            return "<implicit surface lambda: \(userDefinedFunction.objectId)>"
        case .userDefinedFunction(let userDefinedFunction):
            return "<function: \(userDefinedFunction.name)>"
        case .color(let color):
            return "\(color)"
        case .material(let material):
            return "\(material)"
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
        case .builtin, .boundMethod, .lambda, .userDefinedFunction:
            return true
        default:
            return false
        }
    }
}
