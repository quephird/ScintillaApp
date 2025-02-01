//
//  Expression.swift
//  ScintillaApp
//
//  Created by Danielle Kefford on 1/23/25.
//

indirect enum Expression<Depth: Equatable>: Equatable {
    public struct Argument: Equatable {
        public var name: Token
        public var value: Expression<Depth>
    }

    case binary(Expression, Token, Expression)
    case unary(Token, Expression)
    case literal(Token, ScintillaValue)
    case variable(Token, Depth)
    case list(Token, [Expression])
    case tuple2(Token, Expression, Expression)
    case tuple3(Token, Expression, Expression, Expression)
    case function(Token, [Argument], Depth)
    case method(Expression, Token, [Argument])

    var locationToken: Token {
        switch self {
        case .binary(_, let operToken, _):
            return operToken
        case .unary(let locToken, _):
            return locToken
        case .literal(let valueToken, _):
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
        case .method(_, let methodNameToken, _):
            return methodNameToken
        }
    }
}
