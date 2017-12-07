//
//  FileSystemItem.swift
//  TexDocs
//
//  Created by Noah Peeters on 05.12.17.
//  Copyright © 2017 TexDocs. All rights reserved.
//

import Foundation

class FileSystemItem: NSObject {
    var numberOfChildren: Int {
        return children.count
    }
    let url: URL

    var children: [FileSystemItem] = []

    var name: String {
        return url.lastPathComponent
    }

    var isDirectory: Bool {
        return url.hasDirectoryPath
    }

    init(_ url: URL) throws {
        self.url = url
        super.init()

        try updateChildren()
    }

    private func subURLs() -> [URL] {
        guard isDirectory else { return [] }
        return (try? FileManager.default.contentsOfDirectory(at: url, includingPropertiesForKeys: nil, options: [.skipsHiddenFiles, .skipsSubdirectoryDescendants])) ?? []
    }

    func updateChildren() throws {
        let newChildrenURLs = subURLs()

        children = children.filter { newChildrenURLs.contains($0.url) }

        try children.append(contentsOf: newChildrenURLs.filter { url in
            !children.contains { child in
                child.url == url
            }
            }.fileSystemItems())

        children.sort {
            $0.name.lowercased() < $1.name.lowercased()
        }

        try children.forEach {
            try $0.updateChildren()
        }
    }

    func findChild(withURL url: URL) -> FileSystemItem? {
        guard let relativePath = url.path(relativeTo: self.url) else {
            return nil
        }

        return findChild(withRelativePath: relativePath)
    }

    func findChild(withRelativePath relativePath: String, includesRootItemsName: Bool = false) -> FileSystemItem? {
        let components = relativePath.components(separatedBy: "/")
        if includesRootItemsName {
            return findChild(withRelativePathComponents: components.dropFirst())
        } else {
            return findChild(withRelativePathComponents: ArraySlice(components))
        }
    }

    func findChild(withRelativePathComponents relativePath: ArraySlice<String>) -> FileSystemItem? {
        if relativePath.count == 0 {
            return self
        }

        for child in children {
            if child.name == relativePath.first {
                return child.findChild(withRelativePathComponents: relativePath.dropFirst())
            }
        }
        return nil
    }

    func allSubItems() -> [FileSystemItem] {
        return children.map({ [[$0], $0.allSubItems()].flatMap({ $0 }) }).flatMap({ $0 })
    }
}

extension Array where Element == URL {
    func fileSystemItems() throws -> [FileSystemItem] {
        return try map {
            if FileTypeHandler.supportEditing(of: $0) {
                return try EditableFileSystemItem($0)
            } else {
                return try FileSystemItem($0)
            }
        }
    }
}
