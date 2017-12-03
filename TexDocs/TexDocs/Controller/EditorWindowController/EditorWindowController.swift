//
//  EditorWindowController.swift
//  TexDocs
//
//  Created by Noah Peeters on 12.11.17.
//  Copyright © 2017 TexDocs. All rights reserved.
//

import Cocoa
import EonilFileSystemEvents

class EditorWindowController: NSWindowController {
    
    // MARK: Variables
    
    /// Client used to connect to the collaboration server
    let client = CollaborationClient()
    
    /// Local repository
    var repository: GTRepository?
    
    /// File system event monitoring
    var fileSystemMonitor: FileSystemEventMonitor?
    
    /// Content directory
    var rootDirectory: FileSystemItem?
    
    /// Document loaded in this window controller.
    override var document: AnyObject? {
        didSet {
            guard let texDocsDocument = texDocsDocument else {
                return
            }
            loaded(document: texDocsDocument)
        }
    }
    
    let notificationSheet: SimpleSheet = {
        let sheetsStoryboard = NSStoryboard(name: NSStoryboard.Name("Sheets"), bundle: nil)
        return sheetsStoryboard.instantiateController(withIdentifier: NSStoryboard.SceneIdentifier("SimpleSheet")) as! SimpleSheet
    }()
    var sheetIsShown: Bool = false
    
    // Mark: Document
    
    func loaded(document: Document) {
        if let collaborationServer = document.documentData?.collaboration?.server {
            connectTo(collaborationServer: collaborationServer)
        }
        do {
            rootDirectory = try FileSystemItem(dataFolderURL!)
            outlineViewController.reloadData(expandAll: true)
        
            startDirectoryMonitoring()
        } catch {
            showErrorSheet(error)
        }
    }
    
    func editedDocument() {
        DispatchQueue.main.async {
            self.texDocsDocument?.updateChangeCount(.changeDone)
        }
    }
    
    func saveAllDocuments() {
        do {
            if !Thread.current.isMainThread {
                DispatchQueue.main.sync {
                    editorViewController.editorView.saveContent()
                }
            } else {
                editorViewController.editorView.saveContent()
            }
            for item in rootDirectory?.allSubItems().filterEditable() ?? [] {
                try item.save()
            }
        } catch {
            showErrorSheet(error)
        }
    }
    
    func reloadAllDocuments() {
        do {
            for item in rootDirectory?.allSubItems().filterEditable() ?? [] {
                try item.reload()
            }
            DispatchQueue.main.sync {
                editorViewController.editorView.loadContent()
            }
        } catch {
            showErrorSheet(error)
        }
    }

    // MARK: Life cycle
    
    override func windowDidLoad() {
        editorViewController.editorView.collaborationDelegate = self
        outlineViewController.delegate = self
        client.delegate = self
        shouldCascadeWindows = true
    }
    
    deinit {
        stopDirectoryMonitoring()
    }
    
    // MARK: Actions
    
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

extension FileSystemEventFlag {
    static var fileListChangedGroup: FileSystemEventFlag = [
        .itemCreated,
        .itemRemoved,
        .itemRenamed,
        .rootChanged,
        .mustScanSubDirs,
        .mount,
        .unmount
    ]
}
