//
//  CGImage+id.swift
//  ScintillaApp
//
//  Created by Danielle Kefford on 1/29/25.
//

import AppKit
import SwiftUI

extension CGImage: @retroactive Identifiable {
    public var id: ObjectIdentifier {
        ObjectIdentifier(self)
    }
}

extension CGImage {
    public var nsSize: NSSize {
        NSSize(width: self.width, height: self.height)
    }
}

extension CGImage: @retroactive Transferable {
    public static var transferRepresentation: some TransferRepresentation {
        DataRepresentation(exportedContentType: .png) { cgImage in
            let ciContext = CIContext()
            let ciImage = CIImage(cgImage: cgImage)
            return ciContext.pngRepresentation(of: ciImage,
                                               format: .RGBA8,
                                               colorSpace: ciImage.colorSpace!)!
        }
    }
}
