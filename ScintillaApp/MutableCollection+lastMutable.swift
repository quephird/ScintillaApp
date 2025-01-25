//
//  MutableCollection+lastMutable.swift
//  ScintillaApp
//
//  Created by Danielle Kefford on 1/25/25.
//

extension MutableCollection where Self: BidirectionalCollection {
    // Accesses the last element of the collection, mutably.
    //
    // - Precondition: Collection is not empty.
    var lastMutable: Element {
        get {
            precondition(!isEmpty)
            return self[index(before: endIndex)]
        }
        set {
            precondition(!isEmpty)
            self[index(before: endIndex)] = newValue
        }
    }
}
