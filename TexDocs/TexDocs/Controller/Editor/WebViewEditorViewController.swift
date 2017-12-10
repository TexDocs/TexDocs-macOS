//
//  WebViewEditorViewController.swift
//  TexDocs
//
//  Created by Noah Peeters on 10.12.17.
//  Copyright © 2017 TexDocs. All rights reserved.
//

import Cocoa
import WebKit

class WebViewEditorViewController: BaseEditorViewController, EditorController {
    @IBOutlet weak var webView: WKWebView!
    
    var fileSystemItem: FileSystemItem!

    var rootDocumentStructureNode: DocumentStructureNode?
    
    func navigate(to documentStructureNode: DocumentStructureNode) {}

    func collaborationCursorsDidChange() {}

    func receivedChange(in range: NSRange, replaceWith replaceString: String) {}

    func printOperation(withSettings printSettings: [NSPrintInfo.AttributeKey : Any]) -> NSPrintOperation? {
        return nil
    }

    override func willOpen() {
        reloadFromFileSystemItem()
    }

    func reloadFromFileSystemItem() {
        webView.loadFileURL(fileSystemItem.url, allowingReadAccessTo: fileSystemItem.url)
    }

    static let displayName: String = NSLocalizedString("TD_WEB_VIEW_EDITOR_NAME", comment: "Name of the web view editor")

    static func instantiateController(withFileSystemItem fileSystemItem: FileSystemItem, windowController: EditorWindowController) -> EditorController? {
        let editorController = NSStoryboard(name: NSStoryboard.Name(rawValue: "Editors"), bundle: nil).instantiateController(withIdentifier: NSStoryboard.SceneIdentifier(rawValue: "WebViewEditorViewController")) as! WebViewEditorViewController
        editorController.fileSystemItem = fileSystemItem
        return editorController
    }
}

