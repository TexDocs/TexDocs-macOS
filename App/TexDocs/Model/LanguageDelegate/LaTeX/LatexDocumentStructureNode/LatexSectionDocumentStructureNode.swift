//
//  LatexSectionDocumentStructureNode.swift
//  TexDocs
//
//  Created by Noah Peeters on 09.12.17.
//  Copyright © 2017 TexDocs. All rights reserved.
//

import Foundation

struct LatexSectionDocumentStructureNode: AutoHandlingLatexDocumentStructureNode {
    let displayName: String
    let sectionLevel: Int
    let type: DocumentStructureNodeNodeType = .sectioning

    var definitionRange: NSRange
    var effectiveRange: NSRange

    var indentRange: NSRange {
        return NSRange(location: NSMaxRange(definitionRange), length: effectiveRange.length - definitionRange.length)
    }

    var latexSubNodes: [LatexDocumentStructureNode] = []
    private var completed: Bool = false

    init(match: RegularExpressionMatch) {
        self.definitionRange = match.captureGroups[0].range
        self.effectiveRange = NSRange(location: match.captureGroups[0].range.location, length: Int.max)
        self.displayName = match.captureGroups[2].string
        self.sectionLevel = LatexSectionDocumentStructureNode.levelOfSection(withType: match.captureGroups[1].string)
    }

    mutating func handleMatch(_ match: RegularExpressionMatch) -> Bool {
        guard !completed else {
            return false
        }

        let command = match.captureGroups[1].string
        let potentialSectionlevel = LatexSectionDocumentStructureNode.levelOfSection(withType: command)
        guard (command == "end") || (potentialSectionlevel > 0 && potentialSectionlevel <= sectionLevel) else {
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

    private static func levelOfSection(withType type: String) -> Int {
        return [
            "part", "chapter", "section", "subsection", "subsubsection", "paragraph", "subparagraph"
            ].index(of: type) ?? -1
    }
}
