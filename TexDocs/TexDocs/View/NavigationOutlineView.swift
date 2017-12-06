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

    func castedItem<T>(at row: Int) -> T? {
        return item(atRow: row) as? T
    }

    func clickedItem<T>() -> T? {
        return castedItem(at: clickedRow)
    }

    func selectedItem<T>() -> T? {
        return castedItem(at: selectedRow)
    }
}

extension NavigationOutlineView: NSMenuDelegate {
    func menuNeedsUpdate(_ menu: NSMenu) {
        guard clickedRow >= 0 else {
            contextMenuDelegate?.navigationOutlineView(self, updateContextMenu: menu)
            return
        }

        if let fileSystemItem: FileSystemItem = clickedItem() {
            contextMenuDelegate?.navigationOutlineView(self, updateContextMenu: menu, for: fileSystemItem)
        }
    }
}


protocol NavigationOutlineViewContextMenuDelegate: class {
    func navigationOutlineView(_ navigationOutlineView: NavigationOutlineView, updateContextMenu menu: NSMenu, for fileSystemItem: FileSystemItem)
    func navigationOutlineView(_ navigationOutlineView: NavigationOutlineView, updateContextMenu menu: NSMenu)
}
