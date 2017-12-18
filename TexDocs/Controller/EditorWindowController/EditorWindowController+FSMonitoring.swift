//
//  EditorWindowController+FSMonitoring.swift
//  TexDocs
//
//  Created by Noah Peeters on 19.11.17.
//  Copyright © 2017 TexDocs. All rights reserved.
//

import Foundation
import EonilFileSystemEvents

extension EditorWindowController {
    func startDirectoryMonitoring() {
        guard let dataFolderURL = dataFolderURL else {
            return
        }
        
        let gitPath = dataFolderURL.appendingPathComponent(".git", isDirectory: true).path
        
        fileSystemMonitor = FileSystemEventMonitor(pathsToWatch: [dataFolderURL.path]) { [weak self] events in
            for event in events {

                // Ignore any changes in .git folder
                guard !event.path.hasPrefix(gitPath) else {
                    return
                }

                // let url = URL(fileURLWithPath: event.path)
                self?.srcDirectoryDidChange()
            }
        }
    }

    func stopDirectoryMonitoring() {
        fileSystemMonitor = nil
    }

    func srcDirectoryDidChange() {
        do {
            try rootDirectory?.updateChildren()
        } catch {
            showErrorSheet(error)
        }
        outlineViewController.reloadData(inTab: .directory)
        editorWrapperViewController.srcDirectoryDidChange()
    }
}
