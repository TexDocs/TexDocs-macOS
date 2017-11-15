//
//  EditorWindowController+UI.swift
//  TexDocs
//
//  Created by Noah Peeters on 15.11.17.
//  Copyright © 2017 TexDocs. All rights reserved.
//

import Cocoa

extension EditorWindowController {
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
}
