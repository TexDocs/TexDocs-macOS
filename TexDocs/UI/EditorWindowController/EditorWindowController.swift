//
//  EditorWindowController.swift
//  TexDocs
//
//  Created by Noah Peeters on 12.11.17.
//  Copyright © 2017 TexDocs. All rights reserved.
//

import Cocoa
import CollaborationKit

class EditorWindowController: NSWindowController {

    // MARK: - Variables

    /// Content directory
    private(set) var rootDirectory: FileSystemItem?

    lazy var collaborationClient = {
        CollaborationClient(delegate: self)
    }()

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
        // swiftlint:disable force_cast
        return NSStoryboard.sheets.instantiateController(withIdentifier: NSStoryboard.SceneIdentifier("SimpleSheet")) as! SimpleSheet
    }()

    var sheetIsShown: Bool = false

    var selectedSchemeMenuItem: SchemeMenuItem?

    func reloadSchemeSelector() {
        guard let schemes = workspace?.workspaceModel.fetchAllSchemes() else {
            return
        }

        schemeSelector.menu?.removeAllItems()
        if schemes.count > 0 {
            for scheme in schemes {
                let menuItem = SchemeMenuItem(scheme: scheme)
                schemeSelector.menu?.addItem(menuItem)
                if scheme.uuid == workspace?.workspaceModel.selectedSchemeUUID {
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
        dbDeleteScheme(selectedScheme)
    }

    // MARK: Life cycle

    override func windowDidLoad() {
        outlineViewController.delegate = self
        editorWrapperViewController.delegate = self
        shouldCascadeWindows = true
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
        if outlinePanel.isCollapsed == sender.isSelected(forSegment: 0) {
            rootSplitViewController.toggleSidebar(sender)
        }
        if consolePanel.isCollapsed == sender.isSelected(forSegment: 1) {
            centerSplitViewController.toggleSidebar(sender)
        }
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
        dbSelectScheme(newSelection.scheme)
    }

    @IBAction func reconnectButtonClicked(_ sender: Any) {
        if let serverURL = workspace?.workspaceModel.serverURL {
            collaborationClient.connect(to: serverURL)
        }
    }
}

// MARK: - Document
extension EditorWindowController {
    func loaded(document: Workspace) {
        reloadSchemeSelector()

        rootDirectory = generateRootDirectory()
        fileListDidChange()

        if let serverURL = document.workspaceModel.serverURL {
            collaborationClient.connect(to: serverURL)
        }
    }

    func editedDocument() {
        DispatchQueue.main.async {
            self.workspace?.updateChangeCount(.changeDone)
        }
    }

    private func generateRootDirectory() -> FileSystemItem {
        guard let files = workspace?.workspaceModel.currentFilesFetchedResultController.fetch() else {
            return FileSystemItem(dataFolderURL, parent: nil)
        }

        return FileSystemItem.createTree(forFiles: files, atURL: dataFolderURL)
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
}
