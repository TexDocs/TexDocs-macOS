//
//  EditorWindowControllerHelpers.swift
//  TexDocs
//
//  Created by Noah Peeters on 17.11.17.
//  Copyright © 2017 TexDocs. All rights reserved.
//

import Foundation

extension EditorWindowController {
    var texDocsDocument: Document! {
        return self.document as? Document
    }
    
    var workspaceURL: URL! {
        return texDocsDocument.workspaceURL
    }
    
    var dataFolderURL: URL! {
        guard let documentData = texDocsDocument.documentData else { return nil }
        return workspaceURL.appendingPathComponent(documentData.dataFolderName, isDirectory: true)
    }

    func relativePath(of url: URL) -> String? {
        return url.path(relativeTo: workspaceURL)
    }

    func relativePath(of fileSystemItem: FileSystemItem) -> String? {
        return relativePath(of: fileSystemItem.url)
    }

    func relativePathOfOpenedFile() -> String? {
        guard let openedFile = editorWrapperViewController.openedFile else {
            return nil
        }

        return relativePath(of: openedFile)
    }
}
