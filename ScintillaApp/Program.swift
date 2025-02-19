//
//  Program.swift
//  ScintillaApp
//
//  Created by Danielle Kefford on 1/28/25.
//

struct Program<Depth: Equatable>: Equatable {
    public var statements: [Statement<Depth>]
    public var finalExpression: Expression<Depth>
}
