//
//  CollaborationCursor.swift
//  TexDocs
//
//  Created by Noah Peeters on 12.11.17.
//  Copyright © 2017 TexDocs. All rights reserved.
//

import Cocoa

public struct CollaborationCursor {
    public private(set) var range: NSRange
    public let color: NSColor
    public private(set) var relativeFilePath: String

    private func withLenght(_ newLength: Int) -> CollaborationCursor {
        return CollaborationCursor(range: NSRange(location: self.range.location, length: newLength), color: self.color, relativeFilePath: relativeFilePath)
    }

    private func withDeltaLocation(_ deltaLocation: Int) -> CollaborationCursor {
        return CollaborationCursor(range: NSRange(location: self.range.location + deltaLocation, length: self.range.length), color: self.color, relativeFilePath: relativeFilePath)
    }

    private func with(_ range: NSRange) -> CollaborationCursor {
        return CollaborationCursor(range: range, color: self.color, relativeFilePath: relativeFilePath)
    }

    private mutating func updateLocation(_ range: NSRange, inFile relativeFilePath: String) {
        self.range = range
        self.relativeFilePath = relativeFilePath
    }

    private static func withRandomColor() -> CollaborationCursor {
        return CollaborationCursor(range: NSRange(), color: .randomCursorColor(), relativeFilePath: "")
    }
}

extension NSColor {
    fileprivate static func randomCursorColor() -> NSColor {
        let hue = CGFloat(arc4random()) /  CGFloat(UInt32.max)
        return NSColor(hue: hue, saturation: 1, brightness: 1, alpha: 1)
    }
}
