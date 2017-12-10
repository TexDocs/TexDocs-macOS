//
//  ImageFileSystemItem.swift
//  TexDocs
//
//  Created by Noah Peeters on 10.12.17.
//  Copyright © 2017 TexDocs. All rights reserved.
//

import Cocoa

class ImageFileSystemItem: FileSystemItem {
    var image: CachedProperty<NSImage?>!

    override var editorControllerTypes: [EditorController.Type] {
        return [[ImageEditorViewController.self], super.editorControllerTypes].flatMap { $0}
    }

    override init(_ url: URL) throws {
        try super.init(url)
        image = CachedProperty(block: {
            return NSImage(contentsOf: url)
        })
    }

    override func reload() throws {
        image.invalidateCache()
    }
}
