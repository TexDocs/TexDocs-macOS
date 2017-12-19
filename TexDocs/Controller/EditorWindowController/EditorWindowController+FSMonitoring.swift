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
        
        fileSystemMonitor = FileSystemEventMonitor(pathsToWatch: [dataFolderURL.path]) { [weak self] events in
//            for event in events {
//                 let url = URL(fileURLWithPath: event.path)
////                self?.srcDirectoryDidChange()
//            }
            self?.srcDirectoryDidChange()
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
