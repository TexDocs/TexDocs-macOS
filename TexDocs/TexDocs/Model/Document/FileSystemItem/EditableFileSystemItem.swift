//
//  EditableFileSystemItem.swift
//  TexDocs
//
//  Created by Noah Peeters on 05.12.17.
//  Copyright © 2017 TexDocs. All rights reserved.
//

import Cocoa

class EditableFileSystemItem: FileSystemItem {
    let textStorage = NSTextStorage()

    private(set) var modified = false

    override init(_ url: URL) throws {
        try super.init(url)
        try reload()
    }

    func save() throws {
        try textStorage.string.write(to: url, atomically: false, encoding: .utf8)
    }

    func reload() throws {
        let newString = try String(contentsOf: url)
        textStorage.replaceContent(with: newString)
    }

    func createLanguageDelegate() -> SourceCodeViewLanguageDelegate? {
        return allLanguageDelegates[url.pathExtension]?.init()
    }
}

extension Array where Element == FileSystemItem {
    func filterEditable() -> [EditableFileSystemItem] {
        return map { $0 as? EditableFileSystemItem }.flatMap { $0 }
    }
}
