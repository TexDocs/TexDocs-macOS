//
//  SourceCodeViewLanguageDelegate.swift
//  TexDocs
//
//  Created by Noah Peeters on 07.12.17.
//  Copyright © 2017 TexDocs. All rights reserved.
//

import Cocoa

protocol SourceCodeViewLanguageDelegate {
    init()
    func sourceCodeView(_ sourceCodeView: SourceCodeView, updateCodeHighlightingInRange editedRange: NSRange)
    func sourceCodeViewDocumentStructure(_ sourceCodeView: SourceCodeView) -> DocumentStructureNode
}

protocol DocumentStructureNode: NavigationOutlineViewItem {
    var displayName: String { get }
    var type: DocumentStructureNodeNodeType { get }
    var definitionRange: NSRange { get }
    var effectiveRange: NSRange { get }
    var subNodes: [DocumentStructureNode] { get }
}


extension DocumentStructureNode {
    var numberOfChildren: Int {
        return subNodes.count
    }

    var isExpandable: Bool {
        return subNodes.count > 0
    }

    func child(at index: Int) -> NavigationOutlineViewItem {
        return subNodes[index]
    }

    func cell(in outlineView: NSOutlineView, controller: NavigationOutlineViewController) -> NSView? {
        let cell = outlineView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "DocumentStructureNodeCell"), owner: nil) as! DocumentStructureNodeCell
        cell.structureNode = self
        return cell
    }
}

enum DocumentStructureNodeNodeType {
    case root
    case sectioning
    case environment
}

let allLanguageDelegates = [
    "tex": TexSourceCodeViewLanguageDelegate.self
]

struct RegularExpressionMatch {
    let captureGroups: [CaptureGroup]

    class CaptureGroup {
        private let completeString: String
        let range: NSRange

        lazy var string: String = {
            let swiftRange = Range(range, in: completeString)!
            return String(completeString[swiftRange])
        }()

        init(range: NSRange, completeString: String) {
            self.range = range
            self.completeString = completeString
        }
    }
}

extension NSTextCheckingResult {
    func regularExpressionMatch(in string: String) -> RegularExpressionMatch {
        return RegularExpressionMatch(
            captureGroups: (0..<numberOfRanges).map {
                return RegularExpressionMatch.CaptureGroup(range: range(at: $0), completeString: string)
            }
        )
    }
}
