//
//  EditorWindowController.swift
//  TexDocs
//
//  Created by Noah Peeters on 12.11.17.
//  Copyright © 2017 TexDocs. All rights reserved.
//

import Cocoa

class EditorWindowController: NSWindowController {
    
    let client = CollaborationClient()
    
    override func windowDidLoad() {
        editorViewController.editorView.collaborationDelegate = self
        client.delegate = self
    }
    
    var rootSplitViewController: NSSplitViewController {
        return contentViewController as! NSSplitViewController
    }
    
    // MARK: Left
    
    var outlinePanel: NSSplitViewItem {
        return rootSplitViewController.splitViewItems[0]
    }
    
    var outlineViewController: OutlineViewController {
        return outlinePanel.viewController as! OutlineViewController
    }
    
    // MARK: Center
    
    var centerPanel: NSSplitViewItem {
        return rootSplitViewController.splitViewItems[1]
    }
    
    var centerSplitViewController: NSSplitViewController {
        return centerPanel.viewController as! NSSplitViewController
    }
    
    var editorPanel: NSSplitViewItem {
        return centerSplitViewController.splitViewItems[0]
    }
    
    var editorViewController: EditorViewController {
        return editorPanel.viewController as! EditorViewController
    }
    
    var consolePanel: NSSplitViewItem {
        return centerSplitViewController.splitViewItems[1]
    }
    
    var consoleViewController: NSViewController {
        return consolePanel.viewController
    }
    
    // Mark: Right
    
    var pdfViewPanel: NSSplitViewItem {
        return rootSplitViewController.splitViewItems[2]
    }
    
    var pdfViewController: NSViewController {
        return pdfViewPanel.viewController
    }
    
    @IBAction func panelsDidChange(_ sender: NSSegmentedControl) {
        outlinePanel.isCollapsed = !sender.isSelected(forSegment: 0)
        consolePanel.isCollapsed = !sender.isSelected(forSegment: 1)
    }
    
    @IBAction func selectedModeDidChange(_ sender: NSSegmentedControl) {
        switch sender.selectedSegment {
        case 0:
            centerPanel.isCollapsed = false
            pdfViewPanel.isCollapsed = true
        case 1:
            centerPanel.isCollapsed = false
            pdfViewPanel.isCollapsed = false
        case 2:
            centerPanel.isCollapsed = true
            pdfViewPanel.isCollapsed = false
        default:
            break
        }
    }
}
