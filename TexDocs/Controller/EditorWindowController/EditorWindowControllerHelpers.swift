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

    func relativePathInDataFolder(of url: URL) -> String? {
        return url.path(relativeTo: dataFolderURL)
    }

    func relativePathInWorkspace(of url: URL) -> String? {
        return url.path(relativeTo: workspaceURL)
    }

    func relativePathInDataFolder(of fileSystemItem: FileSystemItem) -> String? {
        return relativePathInDataFolder(of: fileSystemItem.url)
    }

    func relativePathOfOpenedFileInDataFolder() -> String? {
        guard let openedFile = editorWrapperViewController.openedFile else {
            return nil
        }

        return relativePathInDataFolder(of: openedFile)
    }
}
