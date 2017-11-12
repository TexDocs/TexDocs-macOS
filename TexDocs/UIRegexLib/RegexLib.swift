//
//  RegexLib.swift
//  UIRegexLib
//
//  Created by Noah Peeters on 11.11.17.
//  Copyright © 2017 TexDocs. All rights reserved.
//

import Foundation

public let NewLineRegex = try! NSRegularExpression(pattern: "\\n", options: .caseInsensitive)

extension String {
    func numberOfLine(in range: NSRange) -> Int {
        return NewLineRegex.numberOfMatches(in: self, options: [], range: range)
    }
}
