//
//  String+Helpers.swift
//  TexDocs
//
//  Created by Noah Peeters on 16.12.17.
//  Copyright © 2017 TexDocs. All rights reserved.
//

import Foundation

extension String {
    subscript(range: NSRange) -> String {
        let swiftRange = Range(range, in: self)!
        return String(self[swiftRange])
    }

    var leadingSpaces: Int {
        for (count, character) in self.enumerated() {
            if character != " " {
                return count
            }
        }
        return count
    }
}

extension NSRange {
    func shifted(by shift: Int) -> NSRange {
        return NSRange(location: location + shift, length: length)
    }
}
