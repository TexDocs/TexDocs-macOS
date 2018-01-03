//
//  FileSystemItem.swift
//  TexDocs
//
//  Created by Noah Peeters on 05.12.17.
//  Copyright © 2017 TexDocs. All rights reserved.
//

import Cocoa

class FileSystemItem: NSObject {
    let url: URL

    var parent: FileSystemItem?
    var children: [FileSystemItem] = []

    var name: String {
        return url.lastPathComponent
    }

    let fileModel: FileModel?

    var isDirectory: Bool {
        return fileModel == nil
    }

    var editorControllerTypes: [EditorController.Type] {
        if isDirectory {
            return [EmptyStateEditorViewController.self]
        } else {
            return [WebViewEditorViewController.self, EmptyStateEditorViewController.self]
        }
    }

    init(_ url: URL, parent: FileSystemItem?, fileModel: FileModel? = nil) {
        self.url = url
        self.fileModel = fileModel
        self.parent = parent
        super.init()
    }

    static func createTree(forFiles files: [FileModel], atURL baseURL: URL) -> FileSystemItem {
        let root = FileSystemItem(baseURL, parent: nil)

        for file in files {
            guard let components = file.relativePath?.components(separatedBy: "/"),
                let fileName = components.last,
                let superFolder = root.findChild(withRelativePathComponents: components.dropLast(), createIfNessesary: true) else {
                continue
            }

            let url = superFolder.url.appendingPathComponent(fileName)

            if let versionedFileSystemItem = file as? VersionedFileModel {
                superFolder.children.append(EditableFileSystemItem(
                    url,
                    parent: superFolder,
                    fileModel: versionedFileSystemItem))
            } else {
                switch url.pathExtension {
                case "png", "jpg", "jpeg":
                    superFolder.children.append(ImageFileSystemItem(
                        superFolder.url.appendingPathComponent(fileName),
                        parent: superFolder,
                        fileModel: file))
                default:
                    superFolder.children.append(FileSystemItem(
                        superFolder.url.appendingPathComponent(fileName),
                        parent: superFolder,
                        fileModel: file))
                }

            }
        }

        return root
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

    private func findChild(withRelativePathComponents relativePath: ArraySlice<String>, createIfNessesary: Bool = false) -> FileSystemItem? {
        if relativePath.count == 0 {
            return self
        }

        let name = relativePath.first

        for child in children {
            if child.name == name {
                return child.findChild(withRelativePathComponents: relativePath.dropFirst())
            }
        }

        guard createIfNessesary, let unwrappedName = name else {
            return nil
        }

        let child = FileSystemItem(url.appendingPathComponent(unwrappedName), parent: self)
        self.children.append(child)
        return child.findChild(withRelativePathComponents: relativePath.dropFirst(), createIfNessesary: true)
    }

    func allSubItems() -> [FileSystemItem] {
        return children.map({ [[$0], $0.allSubItems()].flatMap({ $0 }) }).flatMap({ $0 })
    }
}
