//
//  LatexEnvironmentDocumentStructureNode.swift
//  TexDocs
//
//  Created by Noah Peeters on 09.12.17.
//  Copyright © 2017 TexDocs. All rights reserved.
//

import Foundation

struct LatexEnvironmentDocumentStructureNode: AutoHandlingLatexDocumentStructureNode {
    let displayName: String
    let type: DocumentStructureNodeNodeType = .environment

    let definitionRange: NSRange
    private(set) var effectiveRange: NSRange

    var latexSubNodes: [LatexDocumentStructureNode] = []
    private var completed: Bool = false

    init(match: RegularExpressionMatch) {
        self.definitionRange = match.captureGroups[0].range
        self.effectiveRange = NSRange(location: match.captureGroups[0].range.location, length: Int.max)
        self.displayName = match.captureGroups[2].string
    }

    mutating func handleMatch(_ match: RegularExpressionMatch) -> Bool {
        guard !completed else {
            return false
        }

        guard match.captureGroups[1].string == "end", match.captureGroups[2].string == displayName else {
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

extension LatexEnvironmentDocumentStructureNode: ClosableDocumentStructureNode {
    var closed: Bool {
        return completed
    }

    var closeString: String {
        return "\\end{\(displayName)}"
    }


}
