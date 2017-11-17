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
    
    var texDocsDocument: Document? {
        return self.document as? Document
    }
    
    override var document: AnyObject? {
        didSet {
            guard let texDocsDocument = texDocsDocument else {
                return
            }
            
            if let collaborationServer = texDocsDocument.documentData?.collaboration?.server {
                showSheetStep(text: "Connecting to server...")
                print(collaborationServer.url)
                client.connect(to: collaborationServer.url)
            }
            
            outlineViewController.rootDirectory = FileSystemItem(texDocsDocument.workspaceURL!)
            outlineViewController.outlineView.reloadData()
        }
    }
    
    let currentSheet: SimpleSheet = {
        let sheetsStoryboard = NSStoryboard(name: NSStoryboard.Name("Sheets"), bundle: nil)
        return sheetsStoryboard.instantiateController(withIdentifier: NSStoryboard.SceneIdentifier("SimpleSheet")) as! SimpleSheet
    }()
    private var sheetIsShown: Bool = false
    
    private func showSheetIfRequired() {
        guard !sheetIsShown else { return }
        sheetIsShown = true
        DispatchQueue.main.async { [weak self] in
            guard let unwrappedSelf = self else { return }
            unwrappedSelf.window?.contentViewController?.presentViewControllerAsSheet(unwrappedSelf.currentSheet)
        }
    }
    
    func closeSheet() {
        guard sheetIsShown else { return }
        sheetIsShown = false
        DispatchQueue.main.async { [weak self] in
            self?.currentSheet.dismiss(self)
        }
    }
    
    func showSheetStep(text: String, buttonTitle: String? = nil, progressBarValue: Double? = nil) {
        showSheetIfRequired()
        DispatchQueue.main.async { [weak self] in
            self?.currentSheet.updateLabel(text: text)
            self?.currentSheet.updateButton(title: buttonTitle)
            self?.currentSheet.updateProgressBar(value: progressBarValue, enableButton: progressBarValue == 1)
        }
    }
    
    func showErrorClosingSheet(text: String) {
        showSheetIfRequired()
        DispatchQueue.main.async { [weak self] in
            self?.currentSheet.updateLabel(text: text)
            self?.currentSheet.updateProgressBar(value: nil, enableButton: true)
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
