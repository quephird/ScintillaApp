//
//  Statement.swift
//  ScintillaApp
//
//  Created by Danielle Kefford on 1/23/25.
//

enum Statement<Depth: Equatable>: Equatable {
    case letDeclaration(Token, Expression<Depth>)
    case functionDeclaration(Token, [Token], [Statement<Depth>], Expression<Depth>)
    case expression(Expression<Depth>)

    var locationToken: Token {
        switch self {
        case .letDeclaration(let nameToken, _):
            return nameToken
        case .functionDeclaration(let nameToken, _, _, _):
            return nameToken
        case .expression(let expr):
            return expr.locationToken
        }
    }
}
