//
//  EditorWindowController+OutlineViewControllerDelegate.swift
//  TexDocs
//
//  Created by Noah Peeters on 19.11.17.
//  Copyright © 2017 TexDocs. All rights reserved.
//

import Foundation

extension EditorWindowController {
    func reloadOutlineView() {
        rootDirectory?.updateChildren()
        outlineViewController.outlineView.reloadData()
    }
}

extension EditorWindowController: OutlineViewControllerDelegate {
    func selected(item: FileSystemItem) {
        print("selected \(item.url)")
    }
}
