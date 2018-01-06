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

    func clickedItem() -> ItemWrapper? {
        return castedItem(at: clickedRow)
    }

    func selectedItem() -> ItemWrapper? {
        return castedItem(at: selectedRow)
    }
}

extension NavigationOutlineView: NSMenuDelegate {
    func menuNeedsUpdate(_ menu: NSMenu) {
        guard clickedRow >= 0 else {
            contextMenuDelegate?.navigationOutlineView(self, updateContextMenu: menu)
            return
        }

        if let wrapper: ItemWrapper = clickedItem() {
            contextMenuDelegate?.navigationOutlineView(self, updateContextMenu: menu, for: wrapper)
        }
    }
}

protocol NavigationOutlineViewContextMenuDelegate: class {
    func navigationOutlineView(_ navigationOutlineView: NavigationOutlineView, updateContextMenu menu: NSMenu, for wrapper: ItemWrapper)
    func navigationOutlineView(_ navigationOutlineView: NavigationOutlineView, updateContextMenu menu: NSMenu)
}

class OutlineViewTextField: NSTextField {
    override func rightMouseDown(with event: NSEvent) {
        superview?.rightMouseDown(with: event)
    }
}
