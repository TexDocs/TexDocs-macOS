//
//  LatexRootDocumentStructureNode.swift
//  TexDocs
//
//  Created by Noah Peeters on 09.12.17.
//  Copyright © 2017 TexDocs. All rights reserved.
//

import Foundation

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
