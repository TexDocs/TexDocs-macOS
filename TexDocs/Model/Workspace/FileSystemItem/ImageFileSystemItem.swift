//
//  ImageFileSystemItem.swift
//  TexDocs
//
//  Created by Noah Peeters on 10.12.17.
//  Copyright © 2017 TexDocs. All rights reserved.
//

import Cocoa

class ImageFileSystemItem: FileSystemItem {
    lazy var image: CachedProperty<NSImage?> = CachedProperty(block: { [weak self] in
        guard let data = self?.fileModel?.data?.data else { return nil }
        return NSImage(data: data)
    })

    override var editorControllerTypes: [EditorController.Type] {
        return [[ImageEditorViewController.self], super.editorControllerTypes].flatMap { $0}
    }
}
