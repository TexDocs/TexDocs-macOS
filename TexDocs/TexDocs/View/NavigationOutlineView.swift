//
//  NavigationOutlineView.swift
//  TexDocs
//
//  Created by Noah Peeters on 05.12.17.
//  Copyright © 2017 TexDocs. All rights reserved.
//

import Cocoa

class NavigationOutlineView: NSOutlineView {

    weak var contextMenuDelegate: NavigationOutlineViewContextMenuDelegate?

    override var menu: NSMenu? {
        get {
            return super.menu
        }
        set {
            newValue?.delegate = self
            super.menu = newValue
        }
    }

    private var clickedItem: Any? {
        return item(atRow: clickedRow)
    }
}

extension NavigationOutlineView: NSMenuDelegate {
    func menuNeedsUpdate(_ menu: NSMenu) {
        guard clickedRow >= 0 else {
            contextMenuDelegate?.navigationOutlineView(self, updateContextMenu: menu)
            return
        }

        guard let fileSystemItem = clickedItem as? FileSystemItem else { return }

        contextMenuDelegate?.navigationOutlineView(self, updateContextMenu: menu, for: fileSystemItem)
    }
}


protocol NavigationOutlineViewContextMenuDelegate: class {
    func navigationOutlineView(_ navigationOutlineView: NavigationOutlineView, updateContextMenu menu: NSMenu, for fileSystemItem: FileSystemItem)
    func navigationOutlineView(_ navigationOutlineView: NavigationOutlineView, updateContextMenu menu: NSMenu)
}

extension NSMenu {
    func addItem(_ item: NSMenuItem, enabled: Bool) {
        item.isEnabled = enabled
        self.addItem(item)
    }
}
