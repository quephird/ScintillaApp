//
//  UserDefinedFunction.swift
//  ScintillaApp
//
//  Created by Danielle Kefford on 2/6/25.
//

import Foundation

struct UserDefinedFunction: Equatable {
    var name: String
    var argumentNames: [Token]
    var enclosingEnvironment: Environment
    var letDecls: [Statement<ResolvedLocation>]
    var returnExpr: Expression<ResolvedLocation>
    var objectId: UUID = UUID()

    // General case
    func call(evaluator: Evaluator, argumentValues: [ScintillaValue]) throws -> ScintillaValue {
        let newEnvironment = evaluator.recycleEnvironment(enclosingEnvironment: self.enclosingEnvironment)

        for (i, argumentName) in argumentNames.enumerated() {
            let argumentValue = argumentValues[i]
            let name: ObjectName = .variableName(argumentName.lexeme)
            newEnvironment.define(name: name, value: argumentValue)
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

        func setArgument(_ index: Int, _ value: Double) {
            guard index < argumentNames.count else { return }

            let argumentName = self.argumentNames[index]
            let name: ObjectName = .variableName(argumentName.lexeme)
            newEnvironment.define(name: name, value: .double(value))
        }

        setArgument(0, a1)
        setArgument(1, a2)
        setArgument(2, a3)

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
