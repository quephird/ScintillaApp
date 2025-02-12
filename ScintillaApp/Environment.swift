//
//  Environment.swift
//  ScintillaApp
//
//  Created by Danielle Kefford on 1/26/25.
//

class Environment: Equatable {
    var enclosingEnvironment: Environment?
    private var values: [ScintillaValue] = []
    private var names: [ObjectName: Int] = [:]

    init(enclosingEnvironment: Environment? = nil) {
        self.enclosingEnvironment = enclosingEnvironment
    }

    public func reserveCapacity(capacity: Int) {
        self.values.reserveCapacity(capacity)
    }

    func define(name: ObjectName, value: consuming ScintillaValue) {
        values.append(value)

        // We only need the names dictionary for methods;
        // everything else is resolved purely by its location
        if case .methodName = name {
            names[name] = values.count - 1
        }
    }

    func undefineAll() {
        self.values = []
        self.names = [:]
    }

    func getValueAtLocation(location: ResolvedLocation) throws -> ScintillaValue {
        let ancestor = try ancestor(depth: location.depth)

        assert(location.index < ancestor.values.count)
        return ancestor.values[location.index]
    }

    func getValue(name: ObjectName) throws -> ScintillaValue {
        if let index = names[name] {
            return values[index]
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
        case .methodName(_, let methodName, _):
            let location = methodName.location()
            throw RuntimeError.undefinedMethod(location, methodName)
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
