//
//  SimpleHighlighter.swift
//  TexDocs
//
//  Created by Noah Peeters on 12.11.17.
//  Copyright © 2017 TexDocs. All rights reserved.
//

import Cocoa

class SimpleHighlighter: SourceCodeHighlightRule {
    let regex: NSRegularExpression
    let colors: [ColorKey]

    init(pattern: String, colors: [ColorKey]) {
        // swiftlint:disable force_try
        self.regex = try! NSRegularExpression(pattern: pattern, options: .caseInsensitive)
        self.colors = colors
    }

    func applyRule(to sourceCodeView: SourceCodeView, range: NSRange) {
        let textStorage = sourceCodeView.textStorage!

        for match in regex.matches(in: textStorage.string, options: [], range: range) {
            for rangeIndex in 1..<match.numberOfRanges {
                let color = ThemesHandler.default.color(for: colors[rangeIndex - 1])
                let range = match.range(at: rangeIndex)
                textStorage.addAttribute(NSAttributedStringKey.foregroundColor, value: color, range: range)
            }
        }
    }
}
