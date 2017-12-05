//
//  OutlineViewController.swift
//  TexDocs
//
//  Created by Noah Peeters on 12.11.17.
//  Copyright © 2017 TexDocs. All rights reserved.
//

import Cocoa

class OutlineViewController: NSViewController {
    @IBOutlet weak var outlineView: NSOutlineView!
    
    weak var delegate: OutlineViewControllerDelegate?
    
    func reloadData(expandAll: Bool = false) {
        outlineView.reloadData()
        if expandAll {
            outlineView.expandItem(delegate?.rootDirectory, expandChildren: true)
        }
    }

    func item(at row: Int) -> FileSystemItem? {
        return outlineView.item(atRow: row) as? FileSystemItem
    }

    @IBAction func newSchemeButtonClicked(_ sender: Any) {
        guard let item = item(at: outlineView.clickedRow) else {
            return
        }

        delegate?.createNewScheme(for: item)
    }
}

extension OutlineViewController: NSOutlineViewDataSource {
    func outlineView(_ outlineView: NSOutlineView, numberOfChildrenOfItem item: Any?) -> Int {
        guard let item = item as? FileSystemItem else { return 1 }
        
        return item.numberOfChildren
    }
    
    func outlineView(_ outlineView: NSOutlineView, child index: Int, ofItem item: Any?) -> Any {
        guard let item = item as? FileSystemItem else {
            return (delegate?.rootDirectory as Any?) ?? 0
        }
        
        return item.children[index]
    }
    
    func outlineView(_ outlineView: NSOutlineView, isItemExpandable item: Any) -> Bool {
        guard let item = item as? FileSystemItem else { return false }
        return item.numberOfChildren > 0
    }
    
    func outlineView(_ outlineView: NSOutlineView, viewFor tableColumn: NSTableColumn?, item: Any) -> NSView? {
        guard let item = item as? FileSystemItem else { return nil }
        
        let cell = outlineView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "FileSystemItemCell"), owner: nil) as! FileSystemItemCell
        cell.iconView.image = NSWorkspace.shared.icon(forFile: item.url.path)
        cell.nameTextField.stringValue = item.url.lastPathComponent
        return cell
    }
}

extension OutlineViewController: NSOutlineViewDelegate {
    func outlineViewSelectionDidChange(_ notification: Notification) {
        guard let item = item(at: outlineView.selectedRow) else {
            return
        }
        delegate?.selected(item: item)
    }
}

protocol OutlineViewControllerDelegate: class {
    var rootDirectory: FileSystemItem? { get }
    func selected(item: FileSystemItem)
    func createNewScheme(for item: FileSystemItem)
}

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
    }
    
    func findChild(withURL url: URL) -> FileSystemItem? {
        guard let relativePath = url.path(relativeTo: self.url) else {
            return nil
        }

        return findChild(withRelativePath: relativePath)
    }

    func findChild(withRelativePath relativePath: String) -> FileSystemItem? {
        return findChild(withRelativePathComponents: relativePath.components(separatedBy: "/"))
    }

    func findChild(withRelativePathComponents relativePath: [String]) -> FileSystemItem? {
        if relativePath.count == 0 {
            return self
        }

        for child in children {
            if child.name == relativePath.first {
                return child.findChild(withRelativePathComponents: Array(relativePath.dropFirst()))
            }
        }
        return nil
    }
    
    func allSubItems() -> [FileSystemItem] {
        return children.map({ [[$0], $0.allSubItems()].flatMap({ $0 }) }).flatMap({ $0 })
    }
}

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

extension Array where Element == FileSystemItem {
    func filterEditable() -> [EditableFileSystemItem] {
        return map { $0 as? EditableFileSystemItem }.flatMap { $0 }
    }
}

extension URL {
    func path(relativeTo base: URL) -> String? {
        let basePath = base.path
        guard path.hasPrefix(basePath) else {
            return nil
        }

        return String(path[basePath.endIndex...].dropFirst())
    }
}
