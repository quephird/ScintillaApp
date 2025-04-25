//
//  Statement.swift
//  ScintillaApp
//
//  Created by Danielle Kefford on 1/23/25.
//

enum Statement<Location: Equatable>: Equatable {
    case letDeclaration(AssignmentPattern, Token, Expression<Location>)
    case functionDeclaration(Token, [Token], [Statement<Location>], Expression<Location>)
    case expression(Expression<Location>)

    var locationToken: Token {
        switch self {
        case .letDeclaration(_, let equalsToken, _):
            return equalsToken
        case .functionDeclaration(let nameToken, _, _, _):
            return nameToken
        case .expression(let expr):
            return expr.locationToken
        }
    }
}
