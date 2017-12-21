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
            guard let texDocsDocument = workspace else {
                return
            }
            loaded(document: texDocsDocument)
        }
    }

    let notificationSheet: SimpleSheet = {
        return NSStoryboard.sheets.instantiateController(withIdentifier: NSStoryboard.SceneIdentifier("SimpleSheet")) as! SimpleSheet
    }()

    func editSchemeSheet(for scheme: SchemeModel) -> EditSchemeSheet {
        let sheet = NSStoryboard.sheets.instantiateController(withIdentifier: NSStoryboard.SceneIdentifier("editSchemeSheet")) as! EditSchemeSheet
        sheet.delegate = self
        sheet.scheme = scheme
        return sheet
    }

    var sheetIsShown: Bool = false
    
    // Mark: Document
    
    func loaded(document: Workspace) {
        reloadSchemeSelector()

        do {
            if !FileManager.default.fileExists(atPath: dataFolderURL.path) {
                try FileManager.default.createDirectory(at: dataFolderURL, withIntermediateDirectories: true, attributes: nil)
            }

            rootDirectory = try FileSystemItem(dataFolderURL)
            srcDirectoryDidChange()
        
            startDirectoryMonitoring()
        } catch {
            showErrorSheet(error)
        }
    }

    func saveAllDocuments() {
        do {
            for item in rootDirectory?.allSubItems() ?? [] {
                try item.save()
            }
        } catch {
            showErrorSheet(error)
        }
    }

    func reloadAllDocuments() {
        DispatchQueue.main.async { [weak self] in
            do {
                for item in self?.rootDirectory?.allSubItems() ?? [] {
                    try item.reload()
                }
            } catch {
                self?.showErrorSheet(error)
            }
        }
    }

    func open(fileSystemItem: FileSystemItem, withEditorControllerType editorControllerType: EditorController.Type?) {
        guard let editorController = instantiateEditorController(for: fileSystemItem, withEditorControllerType: editorControllerType) else {
            showErrorSheet(withCustomMessage: NSLocalizedString("TD_ERROR_INVALID_EDITOR_CONTROLLER", comment: "Error message if the requested editor controller cannot be created"))
            return
        }
        editorWrapperViewController.pushToOpenedFiles(editorController)
    }

    private func instantiateEditorController(for fileSystemItem: FileSystemItem, withEditorControllerType editorControllerType: EditorController.Type?) -> EditorController? {
        return (editorControllerType ?? fileSystemItem.editorControllerTypes.first)?.instantiateController(withFileSystemItem: fileSystemItem, windowController: self)
    }

    var selectedSchemeMenuItem: SchemeMenuItem? = nil

    func reloadSchemeSelector() {
        let schemes = workspace.workspaceModel.fetchAllSchemes()

        schemeSelector.menu?.removeAllItems()
        if schemes.count > 0 {
            for scheme in schemes {
                let menuItem = SchemeMenuItem(scheme: scheme)
                schemeSelector.menu?.addItem(menuItem)
                if scheme.uuid == workspace.workspaceModel.selectedSchemeUUID {
                    schemeSelector.select(menuItem)
                }
            }
            schemeSelectorSelectionDidChange(self)

            schemeSelector.menu?.addItem(NSMenuItem.separator())
            schemeSelector.menu?.addItem(withTitle: NSLocalizedString("TD_CONTEXTMENU_ITEM_EDIT_SCHEME", comment: "Menu item to edit the selected scheme"), action: #selector(editScheme), keyEquivalent: "")
            schemeSelector.menu?.addItem(withTitle: NSLocalizedString("TD_CONTEXTMENU_ITEM_DELETE_SCHEME", comment: "Menu item to delete the selected scheme"), action: #selector(deleteScheme), keyEquivalent: "")
            typesetButton.isEnabled = true
        } else {
            selectedSchemeMenuItem = nil
            typesetButton.isEnabled = false
        }
    }

    @objc func editScheme() {
        guard let selectedScheme = selectedSchemeMenuItem?.scheme else {
            return
        }
        schemeSelectorSelectionDidChange(self)
        let sheet = editSchemeSheet(for: selectedScheme)
        window?.contentViewController?.presentViewControllerAsSheet(sheet)
    }

    @objc func deleteScheme() {
        guard let selectedScheme = selectedSchemeMenuItem?.scheme else {
            return
        }
        schemeSelectorSelectionDidChange(self)

        workspace.asyncDatabaseOperations(operations: {
            $0.delete(selectedScheme)
        }, completion: { _ in
            self.reloadSchemeSelector()
        })
    }

    // MARK: Life cycle
    
    override func windowDidLoad() {
        outlineViewController.delegate = self
        editorWrapperViewController.delegate = self
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
    @IBOutlet weak var connectionStatusToolbarItem: NSImageView!

    // MARK: Actions

    override func changeFont(_ sender: Any?) {
        UserDefaults.updateFontFromFontPanel()
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
        workspace.workspaceModel.selectedSchemeUUID = newSelection.scheme.uuid
    }

    @IBAction func reconnectButtonClicked(_ sender: Any) {
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
