//
//  EditorWindowController+FSMonitoring.swift
//  TexDocs
//
//  Created by Noah Peeters on 19.11.17.
//  Copyright © 2017 TexDocs. All rights reserved.
//

import Foundation

extension EditorWindowController {
    func fileListDidChange() {
        outlineViewController.reloadData(inTab: .directory)
        editorWrapperViewController.fileListDidChange()
    }
}
