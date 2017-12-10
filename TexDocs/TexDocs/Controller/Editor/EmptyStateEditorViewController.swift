//
//  EmptyStateEditorViewController.swift
//  TexDocs
//
//  Created by Noah Peeters on 10.12.17.
//  Copyright © 2017 TexDocs. All rights reserved.
//

import Cocoa

class EmptyStateEditorViewController: NSViewController, Editor {
    @IBOutlet weak var imageView: NSImageView!
    @IBOutlet weak var openInButton: NSButton!


    var fileSystemItem: FileSystemItem!

    var rootDocumentStructureNode: DocumentStructureNode?

    func saveContentToFileSystemItem() {}

    func reloadContentFromFileSystemItem() {}

    func navigate(to documentStructureNode: DocumentStructureNode) {}

    func collaborationCursorsDidChange() {}

    func receivedChange(in range: NSRange, replaceWith replaceString: String) {}

    func printOperation(withSettings printSettings: [NSPrintInfo.AttributeKey : Any]) -> NSPrintOperation? {
        return nil
    }

    func removeFromSuperview() {
        view.removeFromSuperview()
    }

    override func viewDidLoad() {
        let workspace = NSWorkspace.shared

        imageView.image = workspace.icon(forFile: fileSystemItem.url.path)

        guard let applicationPath = workspace.urlForApplication(toOpen: fileSystemItem.url) else {
            openInButton.isHidden = true
            return
        }
        openInButton.isHidden = false
        openInButton.title = "Open in \(applicationPath.lastPathComponent)"
    }

    @IBAction func openInButtonClicked(_ sender: Any) {
        NSWorkspace.shared.open(fileSystemItem.url)
    }

    static func instantiateController(withFileSystemItem fileSystemItem: FileSystemItem) -> Editor {
        let editorController = NSStoryboard(name: NSStoryboard.Name(rawValue: "Editors"), bundle: nil).instantiateController(withIdentifier: NSStoryboard.SceneIdentifier(rawValue: "EmptyStateEditorViewController")) as! EmptyStateEditorViewController
        editorController.fileSystemItem = fileSystemItem
        return editorController
    }
}
