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

        dbCreateScheme(withName: item.name, forFileAtPath: path)
    }

    func outlineViewController(_ outlineViewController: NavigationOutlineViewController, encounterdError error: Error) {
        showErrorSheet(error)
    }

    func outlineViewController(_ outlineViewController: NavigationOutlineViewController, createNewFileItemWithType type: NewFileItemType, withSuperItem superItem: FileSystemItem) {
        let sheet = newFileSystemItemSheet(forType: type, withSuperItem: superItem)
        window?.contentViewController?.presentViewControllerAsSheet(sheet)
    }

    func outlineViewController(_ outlineViewController: NavigationOutlineViewController, addFilesToSuperItem item: FileSystemItem) {

        guard let window = window else {
            return
        }

        let openPanel = NSOpenPanel()
        openPanel.canChooseFiles = true
        openPanel.canChooseDirectories = false
        openPanel.allowsMultipleSelection = true

        openPanel.beginSheetModal(for: window) { response in
            guard response == .OK else { return }

            DispatchQueue.global(qos: .background).async {
                for url in openPanel.urls {
                    guard let data = try? Data(contentsOf: url, options: []) else { continue }
                    self.dbUserAddedBinaryFile(withName: url.lastPathComponent, withData: data, withSuperItem: item)
                }
            }
        }
    }

    func outlineViewController(_ outlineViewController: NavigationOutlineViewController, deleteItem item: FileSystemItem) {

    }
}
