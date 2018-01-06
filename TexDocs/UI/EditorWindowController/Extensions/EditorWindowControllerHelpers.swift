//
//  EditorWindowControllerHelpers.swift
//  TexDocs
//
//  Created by Noah Peeters on 17.11.17.
//  Copyright © 2017 TexDocs. All rights reserved.
//

import Foundation

extension EditorWindowController {
    var workspace: Workspace? {
        return self.document as? Workspace
    }

    var workspaceURL: URL! {
        return workspace?.workspaceURL
    }

    var dataFolderURL: URL! {
        return workspaceURL.appendingPathComponent("Data", isDirectory: true)
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
