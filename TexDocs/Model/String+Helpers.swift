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

extension Data {
    func generateHash() -> Data {
        var hash = [UInt8](repeating: 0, count: Int(CC_SHA256_DIGEST_LENGTH))
        withUnsafeBytes {
            _ = CC_SHA256($0, CC_LONG(count), &hash)
        }
        return Data(bytes: hash)
    }
}
