//
//  EditableFileSystemItem.swift
//  TexDocs
//
//  Created by Noah Peeters on 05.12.17.
//  Copyright © 2017 TexDocs. All rights reserved.
//

import Foundation

class EditableFileSystemItem: FileSystemItem {
    var text: String {
        didSet {
            modified = true
        }
    }

    private(set) var modified = false

    override init(_ url: URL) throws {
        text = try String(contentsOf: url)

        try super.init(url)
    }

    func save() throws {
        if modified {
            try text.write(to: url, atomically: false, encoding: .utf8)
            modified = false
        }
    }

    func reload() throws {
        text = try String(contentsOf: url)
        modified = false
    }
}

extension Array where Element == FileSystemItem {
    func filterEditable() -> [EditableFileSystemItem] {
        return map { $0 as? EditableFileSystemItem }.flatMap { $0 }
    }
}
