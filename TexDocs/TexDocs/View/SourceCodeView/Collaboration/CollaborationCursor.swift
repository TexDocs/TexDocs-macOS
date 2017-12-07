//
//  CollaborationCursor.swift
//  TexDocs
//
//  Created by Noah Peeters on 12.11.17.
//  Copyright © 2017 TexDocs. All rights reserved.
//

import Cocoa

struct CollaborationCursor {
    var range: NSRange
    let color: NSColor
    var relativeFilePath: String
    
    func withLenght(_ newLength: Int) -> CollaborationCursor {
        return CollaborationCursor(range: NSRange(location: self.range.location, length: newLength), color: self.color, relativeFilePath: relativeFilePath)
    }
    
    func withDeltaLocation(_ deltaLocation: Int) -> CollaborationCursor {
        return CollaborationCursor(range: NSRange(location: self.range.location + deltaLocation, length: self.range.length), color: self.color, relativeFilePath: relativeFilePath)
    }
    
    func with(_ range: NSRange) -> CollaborationCursor {
        return CollaborationCursor(range: range, color: self.color, relativeFilePath: relativeFilePath)
    }
    
    mutating func updateLocation(_ range: NSRange, inFile relativeFilePath: String) {
        self.range = range
        self.relativeFilePath = relativeFilePath
    }
    
    static func withRandomColor() -> CollaborationCursor {
        return CollaborationCursor(range: NSRange(), color: NSColor.red, relativeFilePath: "")
    }
}
