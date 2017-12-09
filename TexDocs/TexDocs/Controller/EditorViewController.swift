//
//  EditorViewController.swift
//  TexDocs
//
//  Created by Noah Peeters on 12.11.17.
//  Copyright © 2017 TexDocs. All rights reserved.
//

import Cocoa

class EditorViewController: NSViewController {
    @IBOutlet var editorView: CollaborationSourceCodeView!
    @IBOutlet weak var emptyStateImage: NSImageView!
    @IBOutlet weak var emptyStateOpenInButton: NSButton!

    private var opendFile: FileSystemItem?

    func open(_ item: FileSystemItem) {
        opendFile = item
        if let editableFileSystemItem = item as? EditableFileSystemItem {
            editorView.openFile(editableFileSystemItem)
            updateEmptyState(withItem: nil)
        } else {
            editorView.openFile(nil)
            updateEmptyState(withItem: item)
        }
    }

    private func updateEmptyState(withItem item: FileSystemItem?) {
        guard let item = item else {
            emptyStateImage.isHidden = true
            emptyStateOpenInButton.isHidden = true
            return
        }

        emptyStateImage.isHidden = false
        emptyStateImage.image = NSWorkspace.shared.icon(forFile: item.url.path)

        guard let defaultApplicationName = NSWorkspace.shared.urlForApplication(toOpen: item.url)?.lastPathComponent else {
            emptyStateOpenInButton.isHidden = true
            return
        }

        emptyStateOpenInButton.isHidden = false
        emptyStateOpenInButton.title = "Open in \(defaultApplicationName)"
        emptyStateOpenInButton.sizeToFit()
    }

    @IBAction func openInDefaultApplication(_ sender: Any) {
        NSWorkspace.shared.open(opendFile!.url)
    }

}
