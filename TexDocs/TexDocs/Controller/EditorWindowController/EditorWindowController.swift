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
    var repository: GTRepository?
    
    override var document: AnyObject? {
        didSet {
            guard let texDocsDocument = texDocsDocument else {
                return
            }
            
            if let collaborationServer = texDocsDocument.documentData?.collaboration?.server {
                connectTo(collaborationServer: collaborationServer)
            }
            
            outlineViewController.rootDirectory = FileSystemItem(texDocsDocument.workspaceURL!)
            outlineViewController.outlineView.reloadData()
        }
    }
    
    func connectTo(collaborationServer: DocumentData.Collaboration.Server) {
        showConnectingSheet()
        client.connect(to: collaborationServer.url)
    }
    
    func editedDocument() {
        DispatchQueue.main.async {
            self.texDocsDocument?.updateChangeCount(.changeDone)
        }
    }
    
    let currentSheet: SimpleSheet = {
        let sheetsStoryboard = NSStoryboard(name: NSStoryboard.Name("Sheets"), bundle: nil)
        return sheetsStoryboard.instantiateController(withIdentifier: NSStoryboard.SceneIdentifier("SimpleSheet")) as! SimpleSheet
    }()
    var sheetIsShown: Bool = false
    
    override func windowDidLoad() {
        editorViewController.editorView.collaborationDelegate = self
        client.delegate = self
        shouldCascadeWindows = true
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
