//
//  Statement.swift
//  ScintillaApp
//
//  Created by Danielle Kefford on 1/23/25.
//

enum Statement<Depth: Equatable>: Equatable {
    case letDeclaration(Token, Expression<Depth>)
    case expression(Expression<Depth>)

    var locationToken: Token {
        switch self {
        case .letDeclaration(let nameToken, _):
            return nameToken
        case .expression(let expr):
            return expr.locationToken
        }
    }
}
