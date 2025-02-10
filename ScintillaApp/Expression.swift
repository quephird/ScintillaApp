//
//  Expression.swift
//  ScintillaApp
//
//  Created by Danielle Kefford on 1/23/25.
//

indirect enum Expression<Location: Equatable>: Equatable {
    public struct Argument: Equatable {
        public var name: Token?
        public var value: Expression<Location>
    }

    case binary(Expression, Token, Expression)
    case unary(Token, Expression)
    case boolLiteral(Token, Bool)
    case doubleLiteral(Token, Double)
    case variable(Token, Location)
    case list(Token, [Expression])
    case tuple2(Token, Expression, Expression)
    case tuple3(Token, Expression, Expression, Expression)
    // NOTA BENE: The following represents _three_ kinds of objects:
    //
    // * Builtin constructors of Scintilla objects, such as `Camera`, `ImplicitSurface`, etc.
    // * Native standalone functions "registered" in the environment, such as `sin()`, `cos()`, etc.
    // * User-defined functions
    case function(Token, [Token?], Location)
    // ... whereas this case handles only one kind of object:
    //
    // * Builtin methods of Scintilla objects, such as `Shape.translate()`, `Shape.rotateX()`, etc.
    case method(Expression, Token, [Token?])
    case lambda(Token, [Token], Expression)
    case call(Expression, Token, [Argument])

    var locationToken: Token {
        switch self {
        case .binary(_, let operToken, _):
            return operToken
        case .unary(let locToken, _):
            return locToken
        case .boolLiteral(let valueToken, _):
            return valueToken
        case .doubleLiteral(let valueToken, _):
            return valueToken
        case .variable(let nameToken, _):
            return nameToken
        case .list(let leftBracketToken, _):
            return leftBracketToken
        case .tuple2(let leftParenToken, _, _):
            return leftParenToken
        case .tuple3(let leftParenToken, _, _, _):
            return leftParenToken
        case .function(let nameToken, _, _):
            return nameToken
        case .lambda(let leftBraceToken, _, _):
            return leftBraceToken
        case .method(_, let methodNameToken, _):
            return methodNameToken
        case .call(_, let leftParenToken, _):
            return leftParenToken
        }
    }
}
