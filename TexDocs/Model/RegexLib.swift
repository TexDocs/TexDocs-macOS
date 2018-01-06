//
//  RegexLib.swift
//  TexDocs
//
//  Created by Noah Peeters on 19.11.17.
//  Copyright © 2017 TexDocs. All rights reserved.
//

import Foundation

// swiftlint:disable force_try
public let newLineRegex = try! NSRegularExpression(pattern: "\\n", options: .caseInsensitive)

extension String {
    func numberOfLine(in range: NSRange) -> Int {
        return newLineRegex.numberOfMatches(in: self, options: [], range: range)
    }
}
