//
//  UserDefinedFunction.swift
//  ScintillaApp
//
//  Created by Danielle Kefford on 2/6/25.
//

import Foundation

struct UserDefinedFunction: Equatable {
    var name: String
    var parameters: [Parameter]
    var enclosingEnvironment: Environment
    var letDecls: [Statement<ResolvedLocation>]
    var returnExpr: Expression<ResolvedLocation>
    var objectId: UUID = UUID()

    var expectedCapacity: Int {
        return letDecls.count + parameters.count
    }

    // General case
    func call(evaluator: Evaluator, argumentValues: [ScintillaValue]) throws -> ScintillaValue {
        let newEnvironment = evaluator.recycleEnvironment(enclosingEnvironment: self.enclosingEnvironment)
        newEnvironment.reserveCapacity(capacity: self.expectedCapacity)

        for (i, parameter) in parameters.enumerated() {
            let argumentValue = argumentValues[i]

            // NOTA BENE: This is to ensure that if a function parameter
            // has a top-level name associated with it that we define
            // that name in the new environment with its top-level value.
            // We only have to do that for tuples since they are the only
            // parameter types that take an alias.
            switch parameter.pattern {
            case .tuple2, .tuple3:
                if let fullParameterName = parameter.name {
                    let name: ObjectName = .variableName(fullParameterName.lexeme)
                    newEnvironment.define(name: name, value: argumentValue)
                }
            default:
                break
            }

            try evaluator.handlePattern(pattern: parameter.pattern,
                                        value: argumentValue,
                                        environment: newEnvironment)
        }

        let previousEnvironment = evaluator.environment
        evaluator.environment = newEnvironment
        defer {
            evaluator.environment = previousEnvironment
        }

        for letDecl in letDecls {
            try evaluator.execute(statement: letDecl)
        }

        return try evaluator.evaluate(expr: returnExpr)
    }

    // Specific case for a function that oniy takes Doubles and returns a Double
    func call(evaluator: Evaluator, argumentValues a1: Double, _ a2: Double, _ a3: Double) throws -> Double {
        let newEnvironment = evaluator.recycleEnvironment(enclosingEnvironment: self.enclosingEnvironment)
        newEnvironment.reserveCapacity(capacity: self.expectedCapacity)

        func setArgument(_ index: Int, _ value: Double) throws {
            guard index < parameters.count else { return }

            let parameter = self.parameters[index]
            try evaluator.handlePattern(pattern: parameter.pattern,
                                        value: .double(value),
                                        environment: newEnvironment)
        }

        try setArgument(0, a1)
        try setArgument(1, a2)
        try setArgument(2, a3)

        let previousEnvironment = evaluator.environment
        evaluator.environment = newEnvironment
        defer {
            evaluator.environment = previousEnvironment
        }

        for letDecl in letDecls {
            try evaluator.execute(statement: letDecl)
        }

        return try evaluator.evaluateDouble(expr: returnExpr)
    }
}
