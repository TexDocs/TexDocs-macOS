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

        delegate?.outlineViewController(self, createNewFileItemWithType: .file, withSuperItem: item)
    }

    @IBAction func addFiles(_ sender: Any) {
        guard let item: FileSystemItem = outlineView.clickedItem()?.casted() else { return }

        delegate?.outlineViewController(self, addFilesToSuperItem: item)
    }

    @IBAction func newFolder(_ sender: Any) {
        guard let item: FileSystemItem = outlineView.clickedItem()?.casted() else { return }
        delegate?.outlineViewController(self, createNewFileItemWithType: .folder, withSuperItem: item)
    }

    @IBAction func openFile(_ sender: Any) {
        openWrapper(outlineView.clickedItem())
    }

    @IBAction func delete(_ sender: Any) {
        deleteItem(fileSystemItem: outlineView.clickedItem()?.casted())
    }

    // MARK: Event Handler

    private func deleteItem(fileSystemItem: FileSystemItem?) {
        guard let fileSystemItem = fileSystemItem else { return }
        delegate?.outlineViewController(self, deleteItem: fileSystemItem)
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
            } else {
                menu.item(at: 6)?.isEnabled = false
                menu.item(at: 7)?.isEnabled = false
                menu.item(at: 8)?.isEnabled = false
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
        guard let fileSystemItem = fileSystemItemCell.fileSystemItem else { return }
        delegate?.outlineViewController(self, renameItem: fileSystemItem, renameTo: newName)
    }
}

protocol NavigationOutlineViewControllerDelegate: class {
    func rootDirectory(for outlineViewController: NavigationOutlineViewController) -> FileSystemItem?
    func rootStructureNode(for outlineViewCOntroller: NavigationOutlineViewController) -> DocumentStructureNode?
    func outlineViewController(_ outlineViewController: NavigationOutlineViewController, openFileSystemItem item: FileSystemItem, withEditorControllerType editorControllerType: EditorController.Type?)
    func outlineViewController(_ outlineViewController: NavigationOutlineViewController, selectedDocumentStructureNode item: DocumentStructureNode)
    func outlineViewController(_ outlineViewController: NavigationOutlineViewController, createNewSchemeFor item: FileSystemItem)
    func outlineViewController(_ outlineViewController: NavigationOutlineViewController, encounterdError error: Error)
    func outlineViewController(_ outlineViewController: NavigationOutlineViewController, createNewFileItemWithType type: NewFileItemType, withSuperItem superItem: FileSystemItem)
    func outlineViewController(_ outlineViewController: NavigationOutlineViewController, deleteItem item: FileSystemItem)
    func outlineViewController(_ outlineViewController: NavigationOutlineViewController, renameItem item: FileSystemItem, renameTo newName: String)
    func outlineViewController(_ outlineViewController: NavigationOutlineViewController, addFilesToSuperItem item: FileSystemItem)
}
