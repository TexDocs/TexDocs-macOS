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

    var autoTypesetTimer: Timer?
    
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

        do {
            if let collaborationServer = document.documentData?.collaboration?.server {
                connectTo(collaborationServer: collaborationServer)
            } else {
                if !FileManager.default.fileExists(atPath: dataFolderURL.path) {
                    try FileManager.default.createDirectory(at: dataFolderURL, withIntermediateDirectories: true, attributes: nil)
                }
            }

            rootDirectory = try FileSystemItem(dataFolderURL)
            outlineViewController.reloadData(inTab: .directory)
        
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
                editorViewController.editorView.reloadContentFromDisk()
            }
        } catch {
            showErrorSheet(error)
        }
    }

    var selectedSchemeMenuItem: SchemeMenuItem? = nil

    var selectedScheme: DocumentData.Scheme? {
        guard let uuid = selectedSchemeMenuItem?.uuid else { return nil }
        return texDocsDocument.documentData?.scheme(withUUID: uuid)
    }

    func reloadSchemeSelector(selectUUID newSelctedUUID: UUID? = nil) {
        guard let schemes = texDocsDocument.documentData?.schemes else { return }

        let initialUUID = newSelctedUUID ?? selectedSchemeMenuItem?.uuid
        schemeSelector.removeAllItems()

        if schemes.count > 0 {
            for scheme in schemes {
                let menuItem = SchemeMenuItem(scheme: scheme)
                schemeSelector.menu?.addItem(menuItem)
                if scheme.uuid == initialUUID {
                    schemeSelector.select(menuItem)
                }
            }
            schemeSelectorSelectionDidChange(self)

            schemeSelector.menu?.addItem(NSMenuItem.separator())
            schemeSelector.menu?.addItem(withTitle: "Edit Scheme...", action: #selector(editScheme), keyEquivalent: "")
            schemeSelector.menu?.addItem(withTitle: "Delete Scheme", action: #selector(deleteScheme), keyEquivalent: "")
            typesetButton.isEnabled = true
        } else {
            selectedSchemeMenuItem = nil
            typesetButton.isEnabled = false
        }
    }

    @objc func editScheme() {
        schemeSelectorSelectionDidChange(self)
        guard let scheme = selectedScheme else { return }
        let sheet = editSchemeSheet()
        sheet.scheme = scheme
        window?.contentViewController?.presentViewControllerAsSheet(sheet)
    }

    @objc func deleteScheme() {
        schemeSelectorSelectionDidChange(self)
        guard let index = texDocsDocument.documentData?.schemes.index(where: { $0.uuid == selectedScheme?.uuid }) else {
            return
        }

        texDocsDocument.documentData?.schemes.remove(at: index)
        reloadSchemeSelector()
    }

    // MARK: Life cycle
    
    override func windowDidLoad() {
        editorViewController.editorView.collaborationDelegate = self
        editorViewController.editorView.sourceCodeViewDelegate = self
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
    @IBOutlet weak var stopProcessButton: NSButton!
    @IBOutlet weak var autoTypesetToggle: NSButton!

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

    @IBAction func schemeSelectorSelectionDidChange(_ sender: Any) {
        guard let newSelection = schemeSelector.selectedItem as? SchemeMenuItem else {
            schemeSelector.select(selectedSchemeMenuItem)
            return
        }
        selectedSchemeMenuItem = newSelection
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
