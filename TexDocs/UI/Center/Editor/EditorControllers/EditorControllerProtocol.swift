//
//  Editor.swift
//  TexDocs
//
//  Created by Noah Peeters on 10.12.17.
//  Copyright © 2017 TexDocs. All rights reserved.
//

import Cocoa

protocol EditorController: class {
    static var displayName: String { get }
    static func instantiateController(withFileSystemItem fileSystemItem: FileSystemItem, windowController: EditorWindowController) -> EditorController?

    var fileSystemItem: FileSystemItem! { get }
    var rootDocumentStructureNode: DocumentStructureNode? { get }

    func navigate(to documentStructureNode: DocumentStructureNode)
    func collaborationCursorsDidChange()

    func reloadFromFileSystemItem()
    func saveToFileSystemItem()
    func editorControllerWillOpen()

    func printOperation(withSettings printSettings: [NSPrintInfo.AttributeKey: Any]) -> NSPrintOperation?

    // MARK: NSViewController functions
    func removeFromSuperview()
    var view: NSView { get }
}

extension EditorController {
    func reloadFromFileSystemItem() {}
    func saveToFileSystemItem() {}
}

class BaseEditorViewController: NSViewController {
    func removeFromSuperview() {
        view.removeFromSuperview()
    }

    override func viewDidLoad() {
        willOpen()
    }

    func editorControllerWillOpen() {
        willOpen()
    }

    open func willOpen() {}
}
