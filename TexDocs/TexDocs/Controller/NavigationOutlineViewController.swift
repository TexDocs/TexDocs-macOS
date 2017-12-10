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
    @IBOutlet weak var tabBar: ModernTabBar!

    weak var delegate: NavigationOutlineViewControllerDelegate?

    override func viewDidLoad() {
        outlineView.contextMenuDelegate = self
        tabBar.tabBarDelegate = self
    }

    func reloadData(inTab tab: NavigationOutlineViewControllerTabs) {
        guard tab.rawValue == tabBar.selectedButton else {
            return
        }
        outlineView.reloadData()
        outlineView.expandItem(outlineView.item(atRow: 0), expandChildren: true)

    }

    // MARK: Context menu events

    @IBAction func showInFinder(_ sender: Any) {
        guard let item: FileSystemItem = outlineView.clickedItem()?.casted() else { return }
        NSWorkspace.shared.activateFileViewerSelecting([item.url])
    }

    @IBAction func newScheme(_ sender: Any) {
        guard let item: FileSystemItem = outlineView.clickedItem()?.casted() else { return }
        delegate?.outlineViewController(self, createNewSchemeFor: item)
    }

    @IBAction func newFile(_ sender: Any) {
        guard let item: FileSystemItem = outlineView.clickedItem()?.casted() else { return }

        let parentUrl = item.isDirectory ? item.url : item.url.deletingLastPathComponent()
        let newFileURL = parentUrl.appendingPathComponent("Untitled")
        FileManager.default.createFile(atPath: newFileURL.path, contents: nil, attributes: nil)
    }

    @IBAction func openFile(_ sender: Any) {
        openWrapper(outlineView.clickedItem())
    }

    @IBAction func newFolder(_ sender: Any) {
        guard let item: FileSystemItem = outlineView.clickedItem()?.casted() else { return }

        let parentUrl = item.isDirectory ? item.url : item.url.deletingLastPathComponent()
        let newDirectoryURL = parentUrl.appendingPathComponent("Untitled")
        do {
            try FileManager.default.createDirectory(at: newDirectoryURL, withIntermediateDirectories: false, attributes: nil)
        } catch {
            delegate?.outlineViewController(self, encounterdError: error)
        }
    }

    @IBAction func delete(_ sender: Any) {
        deleteItem(fileSystemItem: outlineView.clickedItem()?.casted())
    }

    // MARK: Event Handler

    private func deleteItem(fileSystemItem: FileSystemItem?) {
        guard let fileSystemItem = fileSystemItem else { return }

        do {
            try FileManager.default.removeItem(at: fileSystemItem.url)
        } catch {
            delegate?.outlineViewController(self, encounterdError: error)
        }
    }

    private func rootItem() -> NavigationOutlineViewItem? {
        guard let tab = NavigationOutlineViewControllerTabs(rawValue: tabBar.selectedButton) else { return nil }
        switch tab {
        case .directory:
            return delegate?.rootDirectory(for: self)
        case .structure:
            return delegate?.rootStructureNode(for: self)
        }
    }

    private func openWrapper(_ wrapper: ItemWrapper?) {
        guard let wrapper = wrapper else { return }

        if let fileSystemItem: FileSystemItem = wrapper.casted() {
            delegate?.outlineViewController(self, openFileSystemItem: fileSystemItem, withEditorControllerType: nil)
        } else if let documentStructureNode: DocumentStructureNode = wrapper.casted() {
            delegate?.outlineViewController(self, selectedDocumentStructureNode: documentStructureNode)
        }
    }

    // MARK: Key Events

    override func keyDown(with event: NSEvent) {
        interpretKeyEvents([event])
    }

    override func deleteForward(_ sender: Any?) {
        deleteItem(fileSystemItem: outlineView.selectedItem()?.casted())
    }

    override func deleteBackward(_ sender: Any?) {
        deleteItem(fileSystemItem: outlineView.selectedItem()?.casted())
    }

    enum NavigationOutlineViewControllerTabs: Int {
        case directory
        case structure
    }
}

extension NavigationOutlineViewController: ModernTabBarDelegate {
    func modernTabBar(_ modernTabBar: ModernTabBar, didSelected buttonIndex: Int) {
        guard let tab = NavigationOutlineViewControllerTabs(rawValue: buttonIndex) else {
            return
        }
        reloadData(inTab: tab)
    }
}

extension NavigationOutlineViewController: NSOutlineViewDataSource {
    func outlineView(_ outlineView: NSOutlineView, numberOfChildrenOfItem item: Any?) -> Int {
        guard let item = item as? ItemWrapper else { return 1 }
        
        return item.item.numberOfChildren
    }
    
    func outlineView(_ outlineView: NSOutlineView, child index: Int, ofItem item: Any?) -> Any {
        guard let item = item as? ItemWrapper else {
            guard let newRootItem = rootItem() else {
                return NSNull()
            }
            return ItemWrapper(newRootItem)
        }
        
        return ItemWrapper(item.item.child(at: index))
    }
    
    func outlineView(_ outlineView: NSOutlineView, isItemExpandable item: Any) -> Bool {
        guard let item = item as? ItemWrapper else { return false }
        return item.item.isExpandable
    }
    
    func outlineView(_ outlineView: NSOutlineView, viewFor tableColumn: NSTableColumn?, item: Any) -> NSView? {
        guard let item = item as? ItemWrapper else { return nil }

        return item.item.cell(in: outlineView, controller: self)
    }
}

class ItemWrapper {
    let item: NavigationOutlineViewItem

    init(_ item: NavigationOutlineViewItem) {
        self.item = item
    }

    func casted<T>() -> T? {
        return item as? T
    }
}

extension NavigationOutlineViewController: NSOutlineViewDelegate {
    func outlineViewSelectionDidChange(_ notification: Notification) {
        openWrapper(outlineView.selectedItem())
    }
}

extension NavigationOutlineViewController: NavigationOutlineViewContextMenuDelegate {
    func navigationOutlineView(_ navigationOutlineView: NavigationOutlineView, updateContextMenu menu: NSMenu, for wrapper: ItemWrapper) {

        if let fileSystemItem: FileSystemItem = wrapper.casted() {
            menu.setItemsEnabled(true)

            if let openAsSubmenu = menu.item(at: 1)?.submenu {
                openAsSubmenu.removeAllItems()
                for editor in fileSystemItem.editorControllerTypes {
                    openAsSubmenu.addItem(ClosureMenuItem(title: editor.displayName) { [weak self] in
                        if let unwrappedSelf = self {
                            unwrappedSelf.delegate?.outlineViewController(unwrappedSelf, openFileSystemItem: fileSystemItem, withEditorControllerType: editor)
                        }
                    })
                }
            }

            if fileSystemItem.isDirectory {
                menu.item(at: 4)?.isEnabled = false
            }
        } else {
            menu.setItemsEnabled(false)
        }
    }

    func navigationOutlineView(_ navigationOutlineView: NavigationOutlineView, updateContextMenu menu: NSMenu) {
        menu.setItemsEnabled(false)
    }
}

extension NSMenu {
    func setItemsEnabled(_ enabled: Bool) {
        items.forEach {
            $0.isEnabled = enabled
        }
    }
}

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
    func rootStructureNode(for outlineViewCOntroller: NavigationOutlineViewController) -> DocumentStructureNode?
    func outlineViewController(_ outlineViewController: NavigationOutlineViewController, openFileSystemItem item: FileSystemItem, withEditorControllerType editorControllerType: EditorController.Type?)
    func outlineViewController(_ outlineViewController: NavigationOutlineViewController, selectedDocumentStructureNode item: DocumentStructureNode)
    func outlineViewController(_ outlineViewController: NavigationOutlineViewController, createNewSchemeFor item: FileSystemItem)
    func outlineViewController(_ outlineViewController: NavigationOutlineViewController, encounterdError error: Error)
}
