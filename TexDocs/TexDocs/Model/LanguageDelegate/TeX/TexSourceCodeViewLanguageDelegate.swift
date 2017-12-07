//
//  TexSourceCodeViewLanguageDelegate.swift
//  TexDocs
//
//  Created by Noah Peeters on 07.12.17.
//  Copyright © 2017 TexDocs. All rights reserved.
//

import Foundation

class TexSourceCodeViewLanguageDelegate: SourceCodeViewLanguageDelegate {
    func sourceCodeView(_ sourceCodeView: SourceCodeView, updateCodeHighlightingInRange editedRange: NSRange) {
        let highlightingRules: [SourceCodeHighlightRule] = [
            SimpleHighlighter(pattern: "(\\d+)", colors: [.variable]),
            SimpleHighlighter(pattern: "(\\\\\\w*)", colors: [.keyword]),
            SimpleHighlighter(pattern: "(%.*)$", colors: [.comment]),
            SimpleHighlighter(pattern: "(?:\\\\documentclass|usepackage|input)(?:\\[([^\\]]*)\\])?\\{([^}]*)\\}", colors: [.variable, .variable]),
            SimpleHighlighter(pattern: "(?:\\\\(?:begin|end))\\{([^}]*)\\}", colors: [.variable]),
            SimpleHighlighter(pattern: "(\\$.*?\\$)", colors: [.inlineMath]),
            ]

        let range = sourceCodeView.nsString.lineRange(for: editedRange)

        sourceCodeView.textStorage?.addAttribute(NSAttributedStringKey.foregroundColor, value: ColorSchemeHandler.default.color(forKey: .text), range: range)
        
        for rule in highlightingRules {
            rule.applyRule(to: sourceCodeView, range: range)
        }
    }

    required init() {}
}
