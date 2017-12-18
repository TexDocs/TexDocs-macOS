//
//  LatexDocumentStructureNode.swift
//  TexDocs
//
//  Created by Noah Peeters on 09.12.17.
//  Copyright © 2017 TexDocs. All rights reserved.
//

import Foundation

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
