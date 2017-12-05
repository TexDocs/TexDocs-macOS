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

    var currentTypesetProcess: Process? {
        didSet {
            stopProcessButton.isEnabled = currentTypesetProcess != nil
        }
    }
    
    /// Document loaded in this window controller.
    override var document: AnyObject? {
        didSet {
            loaded(document: texDocsDocument)
        }
    }

    let notificationSheet: SimpleSheet = {
        return NSStoryboard.sheets.instantiateController(withIdentifier: NSStoryboard.SceneIdentifier("SimpleSheet")) as! SimpleSheet
    }()

    func editSchemeSheet() -> EditSchemeSheet {
        let sheet = NSStoryboard.sheets.instantiateController(withIdentifier: NSStoryboard.SceneIdentifier("editSchemeSheet")) as! EditSchemeSheet
        sheet.delegate = self
        return sheet
    }

    var sheetIsShown: Bool = false
    
    // Mark: Document
    
    func loaded(document: Document) {
        reloadSchemeSelector()

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
            self.texDocsDocument.updateChangeCount(.changeDone)
        }
    }

    func saveAllDocuments() {
        do {
            DispatchQueue.ensureMain {
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

    var selectedSchemeMenuItem: SchemeMenuItem? {
        return schemeSelector.selectedItem as? SchemeMenuItem
    }

    var selectedScheme: DocumentData.Scheme? {
        guard let uuid = selectedSchemeMenuItem?.uuid else { return nil }
        return texDocsDocument.documentData?.scheme(withUUID: uuid)
    }

    func reloadSchemeSelector(selectUUID newSelctedUUID: UUID? = nil) {
        guard let schemes = texDocsDocument.documentData?.schemes else { return }

        let initialUUID = newSelctedUUID ?? selectedSchemeMenuItem?.uuid
        schemeSelector.removeAllItems()

        for scheme in schemes {
            let menuItem = SchemeMenuItem(scheme: scheme)
            schemeSelector.menu?.addItem(menuItem)
            if scheme.uuid == initialUUID {
                schemeSelector.select(menuItem)
            }
        }

        let enableButtons = schemes.count > 0
        typesetButton.isEnabled = enableButtons
        editSchemeButton.isEnabled = enableButtons
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

    // MARK: Outlets

    @IBOutlet weak var schemeSelector: NSPopUpButton!
    @IBOutlet weak var typesetButton: NSButton!
    @IBOutlet weak var editSchemeButton: NSButton!
    @IBOutlet weak var stopProcessButton: NSButton!

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

    @IBAction func typesetButtonClicked(_ sender: Any) {
        typeset()
    }
    
    @IBAction func stopProcessButtonClicked(_ sender: Any) {
        currentTypesetProcess?.terminate()
    }

    @IBAction func editSchemeButtonClicked(_ sender: Any) {
        guard let scheme = selectedScheme else { return }
        let sheet = editSchemeSheet()
        sheet.scheme = scheme
        window?.contentViewController?.presentViewControllerAsSheet(sheet)
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

extension NSStoryboard {
    static var sheets: NSStoryboard {
        return NSStoryboard(name: NSStoryboard.Name("Sheets"), bundle: nil)
    }
}
