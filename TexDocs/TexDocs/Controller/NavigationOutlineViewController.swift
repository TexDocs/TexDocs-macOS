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
    
    weak var delegate: OutlineViewControllerDelegate?

    override func viewDidLoad() {
        outlineView.contextMenuDelegate = self
    }

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
        guard let item = item(at: outlineView.clickedRow) else { return }

        delegate?.createNewScheme(for: item)
    }
}

extension NavigationOutlineViewController: NSOutlineViewDataSource {
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

extension NavigationOutlineViewController: NSOutlineViewDelegate {
    func outlineViewSelectionDidChange(_ notification: Notification) {
        guard let item = item(at: outlineView.selectedRow) else {
            return
        }
        delegate?.selected(item: item)
    }
}

extension NavigationOutlineViewController: NavigationOutlineViewContextMenuDelegate {
    func navigationOutlineView(_ navigationOutlineView: NavigationOutlineView, updateContextMenu menu: NSMenu, for fileSystemItem: FileSystemItem) {

        menu.items.forEach {
            $0.isEnabled = !fileSystemItem.isDirectory
        }
    }

    func navigationOutlineView(_ navigationOutlineView: NavigationOutlineView, updateContextMenu menu: NSMenu) {
        menu.items.forEach {
            $0.isEnabled = false
        }
    }
}

protocol OutlineViewControllerDelegate: class {
    var rootDirectory: FileSystemItem? { get }
    func selected(item: FileSystemItem)
    func createNewScheme(for item: FileSystemItem)
}
