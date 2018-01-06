//
//  EditorWindowController+UI.swift
//  TexDocs
//
//  Created by Noah Peeters on 15.11.17.
//  Copyright © 2017 TexDocs. All rights reserved.
//

import Cocoa

// swiftlint:disable force_cast
extension EditorWindowController {
    var rootSplitViewController: NSSplitViewController {
        return contentViewController as! NSSplitViewController
    }

    // MARK: Left

    var outlinePanel: NSSplitViewItem {
        return rootSplitViewController.splitViewItems[0]
    }

    var outlineViewController: NavigationOutlineViewController {
        return outlinePanel.viewController as! NavigationOutlineViewController
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

    var editorWrapperViewController: EditorWrapperViewController {
        return editorPanel.viewController as! EditorWrapperViewController
    }

    var consolePanel: NSSplitViewItem {
        return centerSplitViewController.splitViewItems[1]
    }

    var consoleViewController: ConsoleViewController {
        return consolePanel.viewController as! ConsoleViewController
    }

    // MARK: Right

    var pdfViewPanel: NSSplitViewItem {
        return rootSplitViewController.splitViewItems[2]
    }

    var pdfViewController: PDFViewController {
        return pdfViewPanel.viewController as! PDFViewController
    }
}
