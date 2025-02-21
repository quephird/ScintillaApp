//
//  Helpers.swift
//  ScintillaApp
//
//  Created by Danielle Kefford on 2/18/25.
//

@testable import ScintillaApp
@testable import ScintillaLib

public func makeLexeme(source: String, offset: Int, length: Int) -> Substring {
    let startIndex = source.index(source.startIndex, offsetBy: offset)
    let endIndex = source.index(startIndex, offsetBy: length)
    return source[startIndex..<endIndex]
}

public func resolveStatement(source: String) throws -> Statement<ResolvedLocation> {
    var tokenizer = Tokenizer(source: source)
    let tokens = try tokenizer.scanTokens()
    var parser = Parser(tokens: tokens)
    let parsedStatement = try parser.parseStatement()!
    var resolver = Resolver()

    return try resolver.resolve(statement: parsedStatement)
}

public func resolveExpression(source: String) throws -> Expression<ResolvedLocation> {
    var tokenizer = Tokenizer(source: source)
    let tokens = try tokenizer.scanTokens()
    var parser = Parser(tokens: tokens)
    let parsedExpression = try parser.parseExpression()
    var resolver = Resolver()

    return try resolver.resolve(expression: parsedExpression)
}

public func resolveProgram(source: String) throws -> Program<ResolvedLocation> {
    var tokenizer = Tokenizer(source: source)
    let tokens = try tokenizer.scanTokens()
    var parser = Parser(tokens: tokens)
    let parsedProgram = try parser.parse()
    var resolver = Resolver()

    return try resolver.resolve(program: parsedProgram)
}

extension ScintillaValue {
    func getShape<S: Shape>(shapeType: S.Type) -> S? {
        guard case .shape(let shape) = self else {
            return nil
        }

        return shape as? S
    }

    func getLight<L: Light>(lightType: L.Type) -> L? {
        guard case .light(let light) = self else {
            return nil
        }

        return light as? L
    }

    func getCamera() -> Camera? {
        guard case .camera(let camera) = self else {
            return nil
        }

        return camera
    }

    func getBoolean() -> Bool? {
        guard case .boolean(let boolean) = self else {
            return nil
        }

        return boolean
    }

    func getTuple2() -> (ScintillaValue, ScintillaValue)? {
        guard case .tuple2(let tuple) = self else {
            return nil
        }

        return tuple
    }

    func getTuple3() -> (ScintillaValue, ScintillaValue, ScintillaValue)? {
        guard case .tuple3(let tuple) = self else {
            return nil
        }

        return tuple
    }

    func getList() -> [ScintillaValue]? {
        guard case .list(let list) = self else {
            return nil
        }

        return list
    }

    func getDouble() -> Double? {
        guard case .double(let double) = self else {
            return nil
        }

        return double
    }

    func getLambda() -> UserDefinedFunction? {
        guard case .lambda(let lambda) = self else {
            return nil
        }

        return lambda
    }

    func getUserDefinedFunction() -> UserDefinedFunction? {
        guard case .userDefinedFunction(let udf) = self else {
            return nil
        }

        return udf
    }
}
