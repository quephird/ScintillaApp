//
//  Environment.swift
//  ScintillaApp
//
//  Created by Danielle Kefford on 1/26/25.
//

class Environment: Equatable {
    var enclosingEnvironment: Environment?
    private var values: [ObjectName: ScintillaValue] = [:]

    init(enclosingEnvironment: Environment? = nil) {
        self.enclosingEnvironment = enclosingEnvironment
    }

    func define(name: ObjectName, value: ScintillaValue) {
        values[name] = value
    }

    func assignAtDepth(name: ObjectName, value: ScintillaValue, depth: Int) throws {
        let ancestor = try ancestor(depth: depth)

        if ancestor.values.keys.contains(name) {
            ancestor.values[name] = value
            return
        }

        switch name {
        case .variableName(let variableName):
            let location = variableName.location()
            throw RuntimeError.undefinedVariable(location, variableName)
        case .functionName(let baseName, _):
            let location = baseName.location()
            throw RuntimeError.undefinedFunction(location, baseName)
        }
    }

    func getValueAtDepth(name: ObjectName, depth: Int) throws -> ScintillaValue {
        let ancestor = try ancestor(depth: depth)

        if let value = ancestor.values[name] {
            return value
        }

        switch name {
        case .variableName(let variableName):
            let location = variableName.location()
            throw RuntimeError.undefinedVariable(location, variableName)
        case .functionName(let baseName, _):
            let location = baseName.location()
            throw RuntimeError.undefinedFunction(location, baseName)
        }
    }

    func getValue(name: ObjectName) throws -> ScintillaValue {
        if let value = values[name] {
            return value
        }

        if let enclosingEnvironment {
            return try enclosingEnvironment.getValue(name: name)
        }

        switch name {
        case .variableName(let variableName):
            let location = variableName.location()
            throw RuntimeError.undefinedVariable(location, variableName)
        case .functionName(let baseName, _):
            let location = baseName.location()
            throw RuntimeError.undefinedFunction(location, baseName)
        }
    }

    private func ancestor(depth: Int) throws -> Environment {
        var i = 0
        var ancestor: Environment = self
        while i < depth {
            guard let parent = ancestor.enclosingEnvironment else {
                // NOTA BENE: This should not happen but it _is_ possible
                fatalError("Fatal error: could not find ancestor environment at depth \(depth).")
            }

            ancestor = parent
            i = i + 1
        }

        return ancestor
    }

    static func == (lhs: Environment, rhs: Environment) -> Bool {
        return lhs === rhs
    }
}
