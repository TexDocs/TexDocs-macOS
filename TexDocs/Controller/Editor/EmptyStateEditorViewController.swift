//
//  EmptyStateEditorViewController.swift
//  TexDocs
//
//  Created by Noah Peeters on 10.12.17.
//  Copyright © 2017 TexDocs. All rights reserved.
//

import Cocoa

class EmptyStateEditorViewController: BaseEditorViewController, EditorController {
    @IBOutlet weak var imageView: NSImageView!
    @IBOutlet weak var openInButton: NSButton!

    var fileSystemItem: FileSystemItem!

    var rootDocumentStructureNode: DocumentStructureNode?

    func navigate(to documentStructureNode: DocumentStructureNode) {}

    func collaborationCursorsDidChange() {}

    func receivedChange(in range: NSRange, replaceWith replaceString: String) {}

    func printOperation(withSettings printSettings: [NSPrintInfo.AttributeKey: Any]) -> NSPrintOperation? {
        return nil
    }

    override func willOpen() {
        reloadFromFileSystemItem()
    }

    func reloadFromFileSystemItem() {
        let workspace = NSWorkspace.shared

        imageView.image = fileSystemItem.icon

        guard let applicationPath = workspace.urlForApplication(toOpen: fileSystemItem.url) else {
            openInButton.isHidden = true
            return
        }
        openInButton.isHidden = false
        openInButton.title = "\(NSLocalizedString("TD_OPEN_IN", comment: "Open in <Application name>")) \(applicationPath.lastPathComponent)"
    }

    @IBAction func openInButtonClicked(_ sender: Any) {
        NSWorkspace.shared.open(fileSystemItem.url)
    }

    static let displayName: String = NSLocalizedString("TD_EMPTY_STATE_EDITOR_NAME", comment: "Name of the empty state editor")

    static func instantiateController(withFileSystemItem fileSystemItem: FileSystemItem, windowController: EditorWindowController) -> EditorController? {
        let storyboard = NSStoryboard(name: NSStoryboard.Name(rawValue: "Editors"), bundle: nil)
        // swiftlint:disable force_cast
        let editorController = storyboard.instantiateController(withIdentifier: NSStoryboard.SceneIdentifier(rawValue: "EmptyStateEditorViewController")) as! EmptyStateEditorViewController
        editorController.fileSystemItem = fileSystemItem
        return editorController
    }
}
