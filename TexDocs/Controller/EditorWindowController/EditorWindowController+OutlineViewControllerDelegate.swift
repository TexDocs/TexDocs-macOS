//
//  EditorWindowController+OutlineViewControllerDelegate.swift
//  TexDocs
//
//  Created by Noah Peeters on 19.11.17.
//  Copyright © 2017 TexDocs. All rights reserved.
//

import Foundation

extension EditorWindowController: NavigationOutlineViewControllerDelegate {
    func rootDirectory(for outlineViewController: NavigationOutlineViewController) -> FileSystemItem? {
        return rootDirectory
    }

    func rootStructureNode(for outlineViewCOntroller: NavigationOutlineViewController) -> DocumentStructureNode? {
        return editorWrapperViewController.openedEditorController?.rootDocumentStructureNode
    }

    func outlineViewController(_ outlineViewController: NavigationOutlineViewController, openFileSystemItem item: FileSystemItem, withEditorControllerType editorControllerType: EditorController.Type?) {
        open(fileSystemItem: item, withEditorControllerType: editorControllerType)
    }

    func outlineViewController(_ outlineViewController: NavigationOutlineViewController, selectedDocumentStructureNode item: DocumentStructureNode) {
            editorWrapperViewController.navigate(to: item)
    }

    func outlineViewController(_ outlineViewController: NavigationOutlineViewController, createNewSchemeFor item: FileSystemItem) {
        guard let path = item.url.path(relativeTo: dataFolderURL) else {
            return
        }

        workspace.asyncDatabaseOperations(operations: {
            let scheme = $0.createSchemeModel(name: item.name, path: path)
            self.workspace.workspaceModel.addToSchemes(scheme)
            self.workspace.workspaceModel.selectedSchemeUUID = scheme.uuid
        }, completion: { _ in
            self.reloadSchemeSelector()
        })
    }

    func outlineViewController(_ outlineViewController: NavigationOutlineViewController, encounterdError error: Error) {
        showErrorSheet(error)
    }
}
