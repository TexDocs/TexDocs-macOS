//
//  DocumentStructureNode.swift
//  TexDocs
//
//  Created by Noah Peeters on 09.12.17.
//  Copyright © 2017 TexDocs. All rights reserved.
//

import Cocoa

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

    func path(toPosition position: Int) -> [DocumentStructureNode] {
        var resultPath: [DocumentStructureNode] = []
        path(toPosition: position, resultPath: &resultPath)
        return resultPath
    }

    func path(toPosition position: Int, resultPath: inout [DocumentStructureNode])  {
        resultPath.append(self)

        guard let newPathElement = subNodes.first(where: { $0.effectiveRange.contains(position) }) else {
            return
        }

        newPathElement.path(toPosition: position, resultPath: &resultPath)
    }
}

protocol ClosableDocumentStructureNode {
    var closed: Bool { get }
    var closeString: String { get }
}

enum DocumentStructureNodeNodeType {
    case root
    case sectioning
    case environment
}

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
