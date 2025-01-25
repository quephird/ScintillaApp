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

    case literal(Token, ScintillaValue)
    case variable(Token, Depth)
    case list(Token, [Expression])
    case tuple(Token, Expression, Expression, Expression)
    case object(Expression, Token, [(Argument)])

    var locationToken: Token {
        switch self {
        case .literal(let valueToken, _):
            return valueToken
        case .variable(let nameToken, _):
            return nameToken
        case .list(let leftBracketToken, _):
            return leftBracketToken
        case .tuple(let leftParenToken, _, _, _):
            return leftParenToken
        case .object(_, let leftParenToken, _):
            return leftParenToken
        }
    }
}
