//
//  FileSystemItemCell.swift
//  TexDocs
//
//  Created by Noah Peeters on 12.11.17.
//  Copyright © 2017 TexDocs. All rights reserved.
//

import Cocoa

class FileSystemItemCell: NSTableCellView {
    @IBOutlet weak var iconView: NSImageView!
    @IBOutlet weak var nameTextField: NSTextField!

    var delegate: FileSystemItemCellDelegate?

    var fileSystemItem: FileSystemItem? {
        didSet {
            guard let fileSystemItem = fileSystemItem else { return }
            iconView.image = NSWorkspace.shared.icon(forFile: fileSystemItem.url.path)
            nameTextField.stringValue = fileSystemItem.url.lastPathComponent
        }
    }

    @IBAction func nameChanged(_ sender: Any) {
        delegate?.fileSystemItemCell(self, didChangeNameTo: nameTextField.stringValue)
    }
}

protocol FileSystemItemCellDelegate: class {
    func fileSystemItemCell(_ fileSystemItemCell: FileSystemItemCell, didChangeNameTo newName: String)
}
