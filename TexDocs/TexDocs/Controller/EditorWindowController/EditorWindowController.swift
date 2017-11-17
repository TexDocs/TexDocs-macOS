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
                showSheetStep(text: "Connecting to server...", progressBarValue: .indeterminate)
                print(collaborationServer.url)
                client.connect(to: collaborationServer.url)
            }
            
            outlineViewController.rootDirectory = FileSystemItem(texDocsDocument.workspaceURL!)
            outlineViewController.outlineView.reloadData()
        }
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
    private var sheetIsShown: Bool = false
    
    private func showSheetIfRequired() {
        guard !sheetIsShown else {
            return
        }
        sheetIsShown = true
        window?.contentViewController?.presentViewControllerAsSheet(currentSheet)
    }
    
    func closeSheet() {
        DispatchQueue.main.async { [weak self] in
            guard let unwrappedSelf = self, unwrappedSelf.sheetIsShown else {
                return
            }
            self?.currentSheet.dismiss(self)
        }
    }
    
    func showSheetStep(text: String, buttonTitle: String? = nil, progressBarValue: ProgressBarValue) {
        DispatchQueue.main.async { [weak self] in
            self?.showSheetIfRequired()
            self?.currentSheet.updateLabel(text: text)
            self?.currentSheet.updateButton(title: buttonTitle)
            self?.currentSheet.updateProgressBar(value: progressBarValue)
        }
    }
    
    func showUserNotificationSheet(text: String, action: (() -> Void)? = nil) {
        DispatchQueue.main.async { [weak self] in
            self?.showSheetIfRequired()
            self?.currentSheet.updateLabel(text: text)
            self?.currentSheet.updateButton(title: "Close") {
                self?.closeSheet()
                action?()
            }
            self?.currentSheet.updateProgressBar(value: .hidden)
        }
    }
    
    func showErrorClosingSheet(text: String) {
        DispatchQueue.main.async { [weak self] in
            self?.showSheetIfRequired()
            self?.currentSheet.updateLabel(text: text)
            self?.currentSheet.updateProgressBar(value: .hidden)
            self?.currentSheet.updateButton(title: "Close Project") {
                self?.close()
            }
        }
    }
    
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
