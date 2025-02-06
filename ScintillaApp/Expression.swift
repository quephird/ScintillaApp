//
//  Expression.swift
//  ScintillaApp
//
//  Created by Danielle Kefford on 1/23/25.
//

indirect enum Expression<Depth: Equatable>: Equatable {
    public struct Argument: Equatable {
        public var name: Token?
        public var value: Expression<Depth>
    }

    case binary(Expression, Token, Expression)
    case unary(Token, Expression)
    case literal(Token, ScintillaValue)
    case variable(Token, Depth)
    case list(Token, [Expression])
    case tuple2(Token, Expression, Expression)
    case tuple3(Token, Expression, Expression, Expression)
    case constructor(Token, [Token?], Depth)
    case lambda(Token, [Token], Expression)
    case method(Expression, Token, [Token?])
    case call(Expression, Token, [Argument])

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
        case .constructor(let nameToken, _, _):
            return nameToken
        case .lambda(let leftBraceToken, _, _):
            return leftBraceToken
        case .method(_, let methodNameToken, _):
            return methodNameToken
        case .call(_, let leftParenToken, _):
            return leftParenToken
        }
    }

    // TODO: Do we still need this?
    var baseNameToken: Token? {
        switch self {
        case .call(let calleeExpr, _, _):
            if case .variable(let nameToken, _) = calleeExpr {
                return nameToken
            }

            return calleeExpr.baseNameToken
        default:
            return nil
        }
    }
}
