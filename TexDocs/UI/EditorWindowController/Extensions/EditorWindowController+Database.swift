//
//  EditorWindowController+Database.swift
//  TexDocs
//
//  Created by Noah Peeters on 02.01.18.
//  Copyright © 2018 TexDocs. All rights reserved.
//

import Foundation

extension EditorWindowController {
    func dbCreateScheme(withName name: String, forFileAtPath path: String) {
        workspace?.asyncDatabaseOperations(operations: {
            let scheme = $0.createSchemeModel(name: name, path: path)
            self.workspace?.workspaceModel.addToSchemes(scheme)
            self.workspace?.workspaceModel.selectedSchemeUUID = scheme.uuid
        }, completion: {
            if $0 {
                self.reloadSchemeSelector()
                self.editedDocument()
            }
        })
    }

    func dbDeleteScheme(_ scheme: SchemeModel) {
        workspace?.asyncDatabaseOperations(operations: {
            $0.delete(scheme)
        }, completion: {
            if $0 {
                self.reloadSchemeSelector()
                self.editedDocument()
            }
        })
    }

    func dbSelectScheme(_ scheme: SchemeModel) {
        workspace?.asyncDatabaseOperations(operations: { _ in
            self.workspace?.workspaceModel.selectedSchemeUUID = scheme.uuid
        }, completion: { _ in
            self.editedDocument()
        })
    }

    @discardableResult func dbUserCreateVersionedFile(withName name: String, withSuperItem superItem: FileSystemItem) -> VersionedFileModel? {
        let url = superItem.url.appendingPathComponent(name)
        guard let relativePath = url.path(relativeTo: dataFolderURL) else { return nil }

        return workspace?.syncDatabaseOperations(operations: {
            let fileModel = $0.createVersionedFile(at: relativePath)
            fileModel.workspace = self.workspace?.workspaceModel
            self.workspace?.workspaceModel.appendCommit(fileModel.createCommit!)
            superItem.children.append(EditableFileSystemItem(url, parent: superItem, fileModel: fileModel))
            fileModel.collaborationDelegate = self
            return fileModel
        })
    }

    @discardableResult func dbUserAddedBinaryFile(withName name: String, withData data: Data, withSuperItem superItem: FileSystemItem) -> FileModel? {
        let url = superItem.url.appendingPathComponent(name)
        guard let relativePath = url.path(relativeTo: dataFolderURL) else { return nil }

        return workspace?.syncDatabaseOperations(operations: {
            let fileModel = $0.createBinaryFile(at: relativePath, withData: data)
            fileModel.workspace = self.workspace?.workspaceModel
            self.workspace?.workspaceModel.appendCommit(fileModel.createCommit!)
            superItem.children.append(FileSystemItem(url, parent: superItem, fileModel: fileModel))
            return fileModel
        })
    }

    func dbUserDeleteFile(_ file: FileModel) {
        workspace?.syncDatabaseOperations(operations: {
            let deleteCommit = $0.createDeleteFileCommit(forFile: file)
            workspace?.workspaceModel.appendCommit(deleteCommit)
        })
    }

    func dbUserInsertedText(inFile file: VersionedFileModel, atLocation location: Int, text: String) {
        workspace?.syncDatabaseOperations(operations: {
            let commit = $0.createInsertTextCommit(inFile: file, atLocation: location, text: text)
            self.workspace?.workspaceModel.appendCommit(commit)
        })
    }

    func dbUserDeletedText(inFile file: VersionedFileModel, atLocation location: Int, withLength length: Int) {
        workspace?.syncDatabaseOperations(operations: {
            let commit = $0.createDeleteTextCommit(inFile: file, atLocation: location, withLength: length)
            self.workspace?.workspaceModel.appendCommit(commit)
        })
    }
}
