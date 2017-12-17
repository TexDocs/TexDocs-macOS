//
//  NavigationOutlineViewItem.swift
//  TexDocs
//
//  Created by Noah Peeters on 09.12.17.
//  Copyright © 2017 TexDocs. All rights reserved.
//

import Cocoa


protocol NavigationOutlineViewItem {
    var numberOfChildren: Int { get }
    var isExpandable: Bool { get }
    func child(at index: Int) -> NavigationOutlineViewItem
    func cell(in outlineView: NSOutlineView, controller: NavigationOutlineViewController) -> NSView?
}

extension FileSystemItem: NavigationOutlineViewItem {
    var numberOfChildren: Int {
        return children.count
    }

    var isExpandable: Bool {
        return isDirectory
    }

    func child(at index: Int) -> NavigationOutlineViewItem {
        return children[index]
    }

    func cell(in outlineView: NSOutlineView, controller: NavigationOutlineViewController) -> NSView? {
        let cell = outlineView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "FileSystemItemCell"), owner: nil) as! FileSystemItemCell
        cell.fileSystemItem = self
        cell.delegate = controller
        return cell
    }
}
