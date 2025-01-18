//
//  ScintillaError.swift
//  ScintillaApp
//
//  Created by Danielle Kefford on 1/18/25.
//

import Foundation

public enum ScintillaError: Equatable, Error, LocalizedError {
    case fileCouldNotBeSelected
    case fileCouldNotBeOpened

    public var errorDescription: String? {
        switch self {
        case .fileCouldNotBeSelected:
            "Unable to select file"
        case .fileCouldNotBeOpened:
            "Unable to open file"
        }
    }
}
