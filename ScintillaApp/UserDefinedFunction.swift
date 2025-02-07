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
    var letDecls: [Statement<Int>]
    var returnExpr: Expression<Int>
    var objectId: UUID = UUID()

    func call(evaluator: Evaluator, argumentValues: [ScintillaValue]) throws -> ScintillaValue {
        let newEnvironment = Environment(enclosingEnvironment: enclosingEnvironment)

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
}
