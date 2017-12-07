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

extension EditorWindowController: NavigationOutlineViewControllerDelegate {
    func rootDirectory(for outlineViewController: NavigationOutlineViewController) -> FileSystemItem? {
        return rootDirectory
    }

    func outlineViewController(_ outlineViewController: NavigationOutlineViewController, selectedItem: FileSystemItem) {
        editorViewController.editorView.openFile(selectedItem as? EditableFileSystemItem)
    }

    func outlineViewController(_ outlineViewController: NavigationOutlineViewController, createNewSchemeFor item: FileSystemItem) {
        guard let path = item.url.path(relativeTo: workspaceURL) else {
            return
        }

        let newSceme = DocumentData.Scheme(name: item.name, path: path)
        texDocsDocument.documentData?.schemes.append(newSceme)
        editedDocument()

        reloadSchemeSelector(selectUUID: newSceme.uuid)
    }

    func outlineViewController(_ outlineViewController: NavigationOutlineViewController, encounterdError error: Error) {
        showErrorSheet(error)
    }
}
