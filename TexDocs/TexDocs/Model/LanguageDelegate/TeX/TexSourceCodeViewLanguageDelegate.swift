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
        let range = sourceCodeView.nsString.lineRange(for: editedRange)

        sourceCodeView.textStorage?.addAttribute(NSAttributedStringKey.foregroundColor, value: ThemesHandler.default.color(for: .text), range: range)
        
        for rule in TexSourceCodeViewLanguageDelegate.highlightingRules {
            rule.applyRule(to: sourceCodeView, range: range)
        }
    }

    func sourceCodeViewDocumentStructure(_ sourceCodeView: SourceCodeView) -> DocumentStructureNode {
        return documentStructure(of: sourceCodeView)
    }

    required init() {}

    private func documentClass(of sourceCodeView: SourceCodeView) -> String? {
        let firstMatch = TexSourceCodeViewLanguageDelegate.documentClassRegex.firstMatch(in: sourceCodeView.string, options: [], range: sourceCodeView.stringRange)

        guard let range = firstMatch?.range(at: 1) else {
            return nil
        }

        return sourceCodeView.nsString.substring(with: range)
    }

    private func documentStructure(of sourceCodeView: SourceCodeView) -> DocumentStructureNode {
        var rootNode = LatexRootDocumentStructureNode(range: sourceCodeView.stringRange, latexSubNodes: [])

        TexSourceCodeViewLanguageDelegate.documentStructureRegex.enumerateMatches(in: sourceCodeView.string, options: [], range: sourceCodeView.stringRange) { match, _, _ in
            if let match = match {
                _ = rootNode.recursiveCanHandleMatch(match.regularExpressionMatch(in: sourceCodeView.string))
            }
        }

        return rootNode
    }
}

extension TexSourceCodeViewLanguageDelegate {
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
}

protocol LatexDocumentStructureNode: DocumentStructureNode {
    mutating func recursiveCanHandleMatch(_ match: RegularExpressionMatch) -> Bool

    var latexSubNodes: [LatexDocumentStructureNode] { get set }
}

extension LatexDocumentStructureNode {
    func newNode(for match: RegularExpressionMatch) -> LatexDocumentStructureNode? {
        switch match.captureGroups[1].string {
        case "begin":
            return LatexEnvironmentDocumentStructureNode(match: match)
        case "end":
            return nil
        default:
            return LatexSectionDocumentStructureNode(match: match)
        }
    }

    var subNodes: [DocumentStructureNode] {
        return latexSubNodes
    }
}

protocol AutoHandlingLatexDocumentStructureNode: LatexDocumentStructureNode {
    mutating func handleMatch(_ match: RegularExpressionMatch) -> Bool
}

extension AutoHandlingLatexDocumentStructureNode {
    mutating func recursiveCanHandleMatch(_ match: RegularExpressionMatch) -> Bool {
        guard latexSubNodes.count == 0 || !latexSubNodes[latexSubNodes.count - 1].recursiveCanHandleMatch(match) else {
            return true
        }
        return handleMatch(match)
    }
}

struct LatexRootDocumentStructureNode: AutoHandlingLatexDocumentStructureNode {
    let displayName = "Document"
    let type: DocumentStructureNodeNodeType = .root
    let range: NSRange
    var latexSubNodes: [LatexDocumentStructureNode] = []

    var definitionRange: NSRange {
        return range
    }

    var effectiveRange: NSRange {
        return range
    }

    mutating func handleMatch(_ match: RegularExpressionMatch) -> Bool {
        guard let newNode = newNode(for: match) else {
            return false
        }
        latexSubNodes.append(newNode)
        return true
    }
}

struct LatexEnvironmentDocumentStructureNode: AutoHandlingLatexDocumentStructureNode {
    let displayName: String
    let type: DocumentStructureNodeNodeType = .environment

    let definitionRange: NSRange
    private(set) var effectiveRange: NSRange

    var latexSubNodes: [LatexDocumentStructureNode] = []
    private var completed: Bool = false

    init(match: RegularExpressionMatch) {
        self.definitionRange = match.captureGroups[0].range
        self.effectiveRange = match.captureGroups[0].range
        self.displayName = match.captureGroups[2].string
    }

    mutating func handleMatch(_ match: RegularExpressionMatch) -> Bool {
        guard !completed else {
            return false
        }

        guard match.captureGroups[1].string == "end" else {
            guard let newNode = newNode(for: match) else {
                return false
            }
            latexSubNodes.append(newNode)
            return true
        }

        let newLenght = NSMaxRange(match.captureGroups[0].range) - effectiveRange.location
        effectiveRange = NSRange(location: effectiveRange.location, length: newLenght)
        completed = true
        return true
    }
}

struct LatexSectionDocumentStructureNode: AutoHandlingLatexDocumentStructureNode {
    let displayName: String
    let sectionLevel: Int
    let type: DocumentStructureNodeNodeType = .sectioning

    var definitionRange: NSRange
    var effectiveRange: NSRange

    var latexSubNodes: [LatexDocumentStructureNode] = []
    private var completed: Bool = false

    init(match: RegularExpressionMatch) {
        self.definitionRange = match.captureGroups[0].range
        self.effectiveRange = match.captureGroups[0].range
        self.displayName = match.captureGroups[2].string
        self.sectionLevel = LatexSectionDocumentStructureNode.levelOfSection(withType: match.captureGroups[1].string)
    }

    mutating func handleMatch(_ match: RegularExpressionMatch) -> Bool {
        guard !completed else {
            return false
        }

        let potentialSectionlevel = LatexSectionDocumentStructureNode.levelOfSection(withType: match.captureGroups[1].string)
        guard potentialSectionlevel > 0, potentialSectionlevel <= sectionLevel else {
            guard let newNode = newNode(for: match) else {
                return false
            }
            latexSubNodes.append(newNode)
            return true
        }

        let newLenght = match.captureGroups[0].range.location - effectiveRange.location
        effectiveRange = NSRange(location: effectiveRange.location, length: newLenght)
        completed = true
        return false
    }

    static func levelOfSection(withType type: String) -> Int {
        return [
            "part", "chapter", "section", "subsection", "subsubsection", "paragraph", "subparagraph"
        ].index(of: type) ?? -1
    }
}



