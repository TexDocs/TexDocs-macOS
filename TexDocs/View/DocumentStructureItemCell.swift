//
//  DocumentStructureItemCell.swift
//  TexDocs
//
//  Created by Noah Peeters on 09.12.17.
//  Copyright © 2017 TexDocs. All rights reserved.
//

import Cocoa

class DocumentStructureNodeCell: NSTableCellView {
    @IBOutlet weak var iconView: NSImageView!
    @IBOutlet weak var nameTextField: NSTextField!

    var structureNode: DocumentStructureNode? {
        didSet {
            guard let structureNode = structureNode else { return }
            iconView.image = structureNode.image
            nameTextField.stringValue = structureNode.displayName
        }
    }
}

extension DocumentStructureNode {
    var image: NSImage? {
        switch type {
        case .root:
            return NSImage(named: NSImage.Name(rawValue: "NSHomeTemplate"))
        case .environment:
            return NSImage(named: NSImage.Name(rawValue: "NSTouchBarTextBoxTemplate"))
        case .sectioning:
            return NSImage(named: NSImage.Name(rawValue: "NSListViewTemplate"))
        }
    }
}
