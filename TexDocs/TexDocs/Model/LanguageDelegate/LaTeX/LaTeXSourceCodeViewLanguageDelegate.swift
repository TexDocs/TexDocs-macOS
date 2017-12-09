//
//  LaTeXSourceCodeViewLanguageDelegate.swift
//  TexDocs
//
//  Created by Noah Peeters on 07.12.17.
//  Copyright © 2017 TexDocs. All rights reserved.
//

import Foundation

class LaTeXSourceCodeViewLanguageDelegate: SourceCodeViewLanguageDelegate {
    func sourceCodeView(_ sourceCodeView: SourceCodeView, updateCodeHighlightingInRange editedRange: NSRange) {
        let range = sourceCodeView.nsString.lineRange(for: editedRange)

        sourceCodeView.textStorage?.addAttribute(NSAttributedStringKey.foregroundColor, value: ThemesHandler.default.color(for: .text), range: range)
        
        for rule in LaTeXSourceCodeViewLanguageDelegate.highlightingRules {
            rule.applyRule(to: sourceCodeView, range: range)
        }
    }

    func sourceCodeViewDocumentStructure(_ sourceCodeView: SourceCodeView) -> DocumentStructureNode {
        return documentStructure(of: sourceCodeView)
    }

    required init() {}

    private func documentClass(of sourceCodeView: SourceCodeView) -> String? {
        let firstMatch = LaTeXSourceCodeViewLanguageDelegate.documentClassRegex.firstMatch(in: sourceCodeView.string, options: [], range: sourceCodeView.stringRange)

        guard let range = firstMatch?.range(at: 1) else {
            return nil
        }

        return sourceCodeView.nsString.substring(with: range)
    }

    private func documentStructure(of sourceCodeView: SourceCodeView) -> DocumentStructureNode {
        var rootNode = LatexRootDocumentStructureNode(range: sourceCodeView.stringRange, latexSubNodes: [])

        LaTeXSourceCodeViewLanguageDelegate.documentStructureRegex.enumerateMatches(in: sourceCodeView.string, options: [], range: sourceCodeView.stringRange) { match, _, _ in
            if let match = match {
                _ = rootNode.recursiveCanHandleMatch(match.regularExpressionMatch(in: sourceCodeView.string))
            }
        }
        return rootNode
    }

    private func packages(usedIn sourceCodeView: SourceCodeView) -> [String] {
        return LaTeXSourceCodeViewLanguageDelegate.packageRegex.matches(in: sourceCodeView.string, options: [], range: sourceCodeView.stringRange).map { rawMatch in
            let match = rawMatch.regularExpressionMatch(in: sourceCodeView.string)
            return match.captureGroups[1].string
        }
    }
}

extension LaTeXSourceCodeViewLanguageDelegate {
    static let documentClassRegex = try! NSRegularExpression(pattern: "\\\\documentclass.*?\\{(\\w+)\\}", options: [])
    static let documentStructureRegex = try! NSRegularExpression(pattern: "\\\\(begin|end|(?:part|section|subsection|subsubsection|paragraph|subparagraph)\\*?)\\{(.+?)\\}", options: [])

    static let highlightingRules: [SourceCodeHighlightRule] = [
        SimpleHighlighter(pattern: "(\\d+)", colors: [.variable]),
        SimpleHighlighter(pattern: "(\\\\\\w*)", colors: [.keyword]),
        SimpleHighlighter(pattern: "(%.*)$", colors: [.comment]),
        SimpleHighlighter(pattern: "(?:\\\\documentclass|usepackage|input)(?:\\[([^\\]]*)\\])?\\{([^}]*)\\}", colors: [.variable, .variable]),
        SimpleHighlighter(pattern: "(?:\\\\(?:begin|end))\\{([^}]*)\\}", colors: [.variable]),
        SimpleHighlighter(pattern: "(\\$.*?\\$)", colors: [.inlineMath]),
    ]

    static let packageRegex = try! NSRegularExpression(pattern: "\\\\usepackage\\{(.*?)\\}", options: [])
}



