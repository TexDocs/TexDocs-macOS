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
            outlineViewController.reloadData(inTab: .directory)
        } catch {
            showErrorSheet(error)
        }
    }
}

extension EditorWindowController: NavigationOutlineViewControllerDelegate {
    func rootDirectory(for outlineViewController: NavigationOutlineViewController) -> FileSystemItem? {
        return rootDirectory
    }

    func rootStructureNode(for outlineViewCOntroller: NavigationOutlineViewController) -> DocumentStructureNode? {
        return editorViewController.editorView.rootStructureNode?.value
    }

    func outlineViewController(_ outlineViewController: NavigationOutlineViewController, selectedFileSystemItem item: FileSystemItem) {
        editorViewController.open(item)
    }

    func outlineViewController(_ outlineViewController: NavigationOutlineViewController, selectedDocumentStructureNode item: DocumentStructureNode) {
        editorViewController.editorView.setSelectedRange(item.definitionRange)
        editorViewController.editorView.scrollRangeToVisible(item.effectiveRange)
        window?.makeFirstResponder(editorViewController.editorView)
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
