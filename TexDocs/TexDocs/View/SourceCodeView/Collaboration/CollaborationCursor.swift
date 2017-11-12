//
//  CollaborationCursor.swift
//  TexDocs
//
//  Created by Noah Peeters on 12.11.17.
//  Copyright © 2017 TexDocs. All rights reserved.
//

import Cocoa

struct CollaborationCursor {
    let range: NSRange
    let color: NSColor
    
    func withLenght(_ newLength: Int) -> CollaborationCursor {
        return CollaborationCursor(range: NSRange(location: self.range.location, length: newLength), color: self.color)
    }
    
    func withDeltaLocation(_ deltaLocation: Int) -> CollaborationCursor {
        return CollaborationCursor(range: NSRange(location: self.range.location + deltaLocation, length: self.range.length), color: self.color)
    }
    
    func with(_ range: NSRange) -> CollaborationCursor {
        return CollaborationCursor(range: range, color: self.color)
    }
}
