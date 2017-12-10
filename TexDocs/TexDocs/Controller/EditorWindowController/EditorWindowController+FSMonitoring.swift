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

                let url = URL(fileURLWithPath: event.path)
                self?.srcDirectoryDidChange()
                
                // Ignore other changes as well
                let syncBlock = self?.client.inSync ?? true
                guard !FileTypeHandler.shouldIgnoreEvent(of: url), !syncBlock else {
                    return
                }
                
                if !event.flag.isDisjoint(with: .fileListChangedGroup) {
                    self?.client.scheduleSync()
                } else if event.flag.contains(.itemModified) && !FileTypeHandler.shouldIgnoreModification(of: url) {
                    self?.client.scheduleSync()
                }
            }
        }
    }

    func stopDirectoryMonitoring() {
        fileSystemMonitor = nil
    }

    func srcDirectoryDidChange() {
        do {
            try rootDirectory?.updateChildren()
            outlineViewController.reloadData(inTab: .directory)
        } catch {
            showErrorSheet(error)
        }
        editorWrapperViewController.srcDirectoryDidChange()
    }
}
