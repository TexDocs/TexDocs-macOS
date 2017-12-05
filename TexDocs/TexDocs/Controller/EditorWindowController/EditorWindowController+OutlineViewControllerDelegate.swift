//
//  EditorWindowController+OutlineViewControllerDelegate.swift
//  TexDocs
//
//  Created by Noah Peeters on 19.11.17.
//  Copyright © 2017 TexDocs. All rights reserved.
//

import Foundation

extension EditorWindowController {
    func reloadOutlineView() {
        do {
            try rootDirectory?.updateChildren()
            outlineViewController.outlineView.reloadData()
        } catch {
            showErrorSheet(error)
        }
    }
}

extension EditorWindowController: OutlineViewControllerDelegate {
    func createNewScheme(for item: FileSystemItem) {
        guard let path = item.url.path(relativeTo: workspaceURL) else {
            return
        }

        let newSceme = DocumentData.Scheme(name: item.name, path: path)
        texDocsDocument.documentData?.schemes.append(newSceme)
        editedDocument()

        reloadSchemeSelector(selectUUID: newSceme.uuid)
    }

    func selected(item: FileSystemItem) {
        guard item.url.pathExtension == "tex", let editableItem = item as? EditableFileSystemItem else {
            editorViewController.editorView.openFile(nil)
            return
        }
        editorViewController.editorView.openFile(editableItem)
    }
}
