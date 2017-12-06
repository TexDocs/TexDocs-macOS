//
//  NavigationOutlineViewController.swift
//  TexDocs
//
//  Created by Noah Peeters on 12.11.17.
//  Copyright © 2017 TexDocs. All rights reserved.
//

import Cocoa

class NavigationOutlineViewController: NSViewController {
    @IBOutlet weak var outlineView: NavigationOutlineView!
    
    weak var delegate: NavigationOutlineViewControllerDelegate?

    override func viewDidLoad() {
        outlineView.contextMenuDelegate = self
    }

    func reloadData(expandAll: Bool = false) {
        outlineView.reloadData()
        if expandAll {
            outlineView.expandItem(delegate?.rootDirectory, expandChildren: true)
        }
    }

    // MARK: Context menu events

    @IBAction func showInFinder(_ sender: Any) {
        guard let item: FileSystemItem = outlineView.clickedItem() else { return }
        NSWorkspace.shared.activateFileViewerSelecting([item.url])
    }

    @IBAction func newScheme(_ sender: Any) {
        guard let item: FileSystemItem = outlineView.clickedItem() else { return }
        delegate?.outlineViewController(self, createNewSchemeFor: item)
    }

    @IBAction func newFile(_ sender: Any) {
        guard let item: FileSystemItem = outlineView.clickedItem() else { return }

        let parentUrl = item.isDirectory ? item.url : item.url.deletingLastPathComponent()
        let newFileURL = parentUrl.appendingPathComponent("Untitled")
        FileManager.default.createFile(atPath: newFileURL.path, contents: nil, attributes: nil)
    }

    @IBAction func newFolder(_ sender: Any) {
        guard let item: FileSystemItem = outlineView.clickedItem() else { return }

        let parentUrl = item.isDirectory ? item.url : item.url.deletingLastPathComponent()
        let newDirectoryURL = parentUrl.appendingPathComponent("Untitled")
        do {
            try FileManager.default.createDirectory(at: newDirectoryURL, withIntermediateDirectories: false, attributes: nil)
        } catch {
            delegate?.outlineViewController(self, encounterdError: error)
        }
    }

    @IBAction func delete(_ sender: Any) {
        deleteItem(fileSystemItem: outlineView.clickedItem())
    }

    // MARK: Event Handler

    func deleteItem(fileSystemItem: FileSystemItem?) {
        guard let fileSystemItem = fileSystemItem else { return }

        do {
            try FileManager.default.removeItem(at: fileSystemItem.url)
        } catch {
            delegate?.outlineViewController(self, encounterdError: error)
        }
    }

    // MARK: Key Events

    override func keyDown(with event: NSEvent) {
        interpretKeyEvents([event])
    }

    override func deleteForward(_ sender: Any?) {
        deleteItem(fileSystemItem: outlineView.selectedItem())
    }

    override func deleteBackward(_ sender: Any?) {
        deleteItem(fileSystemItem: outlineView.selectedItem())
    }
}

extension NavigationOutlineViewController: NSOutlineViewDataSource {
    func outlineView(_ outlineView: NSOutlineView, numberOfChildrenOfItem item: Any?) -> Int {
        guard let item = item as? FileSystemItem else { return 1 }
        
        return item.numberOfChildren
    }
    
    func outlineView(_ outlineView: NSOutlineView, child index: Int, ofItem item: Any?) -> Any {
        guard let item = item as? FileSystemItem else {
            return (delegate?.rootDirectory(for: self) as Any?) ?? 0
        }
        
        return item.children[index]
    }
    
    func outlineView(_ outlineView: NSOutlineView, isItemExpandable item: Any) -> Bool {
        guard let item = item as? FileSystemItem else { return false }
        return item.isDirectory
    }
    
    func outlineView(_ outlineView: NSOutlineView, viewFor tableColumn: NSTableColumn?, item: Any) -> NSView? {
        guard let item = item as? FileSystemItem else { return nil }
        
        let cell = outlineView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "FileSystemItemCell"), owner: nil) as! FileSystemItemCell
        cell.fileSystemItem = item
        cell.delegate = self
        return cell
    }
}

extension NavigationOutlineViewController: NSOutlineViewDelegate {
    func outlineViewSelectionDidChange(_ notification: Notification) {
        guard let item: FileSystemItem = outlineView.selectedItem() else { return }
        delegate?.outlineViewController(self, selectedItem: item)
    }
}

extension NavigationOutlineViewController: NavigationOutlineViewContextMenuDelegate {
    func navigationOutlineView(_ navigationOutlineView: NavigationOutlineView, updateContextMenu menu: NSMenu, for fileSystemItem: FileSystemItem) {

        menu.items.forEach {
            $0.isEnabled = true
        }
        if fileSystemItem.isDirectory {
            menu.item(at: 1)?.isEnabled = false
        }
    }

    func navigationOutlineView(_ navigationOutlineView: NavigationOutlineView, updateContextMenu menu: NSMenu) {
        menu.items.forEach {
            $0.isEnabled = false
        }
    }
}

//extension NavigationOutlineViewController: {
//    func navigationOutlineView(_ navigationOutlineView: NavigationOutlineView, deleteFileSystemItem fileSystemItem: FileSystemItem) {
//        deleteItem(fileSystemItem: outlineView.selectedItem())
//    }
//}

extension NavigationOutlineViewController: FileSystemItemCellDelegate {
    func fileSystemItemCell(_ fileSystemItemCell: FileSystemItemCell, didChangeNameTo newName: String) {
        guard let url = fileSystemItemCell.fileSystemItem?.url else { return }
        do {
            if FileManager.default.fileExists(atPath: url.path) {
                try FileManager.default.renameItem(at: url, to: newName)
            }
        } catch {
            delegate?.outlineViewController(self, encounterdError: error)
        }
    }
}

protocol NavigationOutlineViewControllerDelegate: class {
    func rootDirectory(for outlineViewController: NavigationOutlineViewController) -> FileSystemItem?
    func outlineViewController(_ outlineViewController: NavigationOutlineViewController, selectedItem: FileSystemItem)
    func outlineViewController(_ outlineViewController: NavigationOutlineViewController, createNewSchemeFor item: FileSystemItem)
    func outlineViewController(_ outlineViewController: NavigationOutlineViewController, encounterdError error: Error)
}
