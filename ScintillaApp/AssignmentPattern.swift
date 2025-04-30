//
//  AssignmentPattern.swift
//  ScintillaApp
//
//  Created by Danielle Kefford on 4/25/25.
//

enum AssignmentPattern: Equatable {
    case wildcard(Token)
    case variable(Token)
    indirect case tuple2(AssignmentPattern, AssignmentPattern)
    indirect case tuple3(AssignmentPattern, AssignmentPattern, AssignmentPattern)
}
