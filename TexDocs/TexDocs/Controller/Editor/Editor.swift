//
//  Editor.swift
//  TexDocs
//
//  Created by Noah Peeters on 10.12.17.
//  Copyright © 2017 TexDocs. All rights reserved.
//

import Cocoa

protocol Editor: class {
    var fileSystemItem: FileSystemItem! { get }
    var rootDocumentStructureNode: DocumentStructureNode? { get }

    func navigate(to documentStructureNode: DocumentStructureNode)
    func collaborationCursorsDidChange()

    func printOperation(withSettings printSettings: [NSPrintInfo.AttributeKey : Any]) -> NSPrintOperation?

    // MARK: NSViewController functions
    func removeFromSuperview()
    var view: NSView { get }
}

extension NSViewController {
    func removeFromSuperview() {
        view.removeFromSuperview()
    }
}
