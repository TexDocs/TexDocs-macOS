//
//  OutlineViewController.swift
//  TexDocs
//
//  Created by Noah Peeters on 12.11.17.
//  Copyright © 2017 TexDocs. All rights reserved.
//

import Cocoa

class OutlineViewController: NSViewController {

    var rootDirectory: FileSystemItem?
    
    @IBOutlet weak var outlineView: NSOutlineView!
}

extension OutlineViewController: NSOutlineViewDataSource {
    func outlineView(_ outlineView: NSOutlineView, numberOfChildrenOfItem item: Any?) -> Int {
        guard let item = item as? FileSystemItem else { return 1 }
        
        return item.numberOfChildren
    }
    
    func outlineView(_ outlineView: NSOutlineView, child index: Int, ofItem item: Any?) -> Any {
        guard let item = item as? FileSystemItem else {
            return (rootDirectory as Any?) ?? 0
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
    
}

class FileSystemItem: NSObject {
    var numberOfChildren: Int {
        return children.count
    }
    let url: URL
    
    var children: [FileSystemItem]
    
    init(_ url: URL) {
        self.url = url
        
        self.children = (try? FileManager.default.contentsOfDirectory(at: url, includingPropertiesForKeys: nil, options: [.skipsHiddenFiles, .skipsSubdirectoryDescendants]).map { subURL in
            FileSystemItem(subURL)
        }) ?? []
        
        super.init()
    }
}
