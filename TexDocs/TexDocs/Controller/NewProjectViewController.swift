//
//  NewProjectViewController.swift
//  TexDocs
//
//  Created by Noah Peeters on 12.11.17.
//  Copyright © 2017 TexDocs. All rights reserved.
//

import Cocoa

class NewProjectViewController: NSViewController {

    @IBOutlet weak var joinRadioButton: NSButton!
    @IBOutlet weak var createRadioButton: NSButton!
    @IBOutlet weak var saveButton: NSButton!
    @IBOutlet weak var serverURLTextField: NSTextField!
    @IBOutlet weak var repoURLTextField: NSTextField! {
        didSet {
            repoURLTextField.isHidden = true
        }
    }
    
    private(set) var method: NewProjectOpenMethod?
    
    override func viewDidDisappear() {
        super.viewDidDisappear()
        NSApp.stopModal()
    }
    
    @IBAction func joinRadioButtonPressed(_ sender: NSButton) {
        repoURLTextField.isHidden = true
        saveButton.title = "Join"
        createRadioButton.state = .off
    }
    
    @IBAction func createRadioButtonPressed(_ sender: NSButton) {
        repoURLTextField.isHidden = false
        saveButton.title = "Create"
        joinRadioButton.state = .off
    }
    
    @IBAction func cancel(_ sender: Any) {
        view.window?.close()
        NSApp.stopModal(withCode: .cancel)
    }
    
    @IBAction func save(_ sender: Any) {
        guard let window = view.window else {
            return
        }
        
        let savePanel = NSSavePanel()
        savePanel.prompt = "Create"
        
        savePanel.beginSheetModal(for: window) { [weak self] response in
            if response == .OK, let url = savePanel.url, let unwrappedSelf = self {
                
                if unwrappedSelf.joinRadioButton.state == .on {
                    unwrappedSelf.method = .join(
                        serverURL: unwrappedSelf.serverURLTextField.stringValue,
                        localURL: url)
                } else {
                    unwrappedSelf.method = .create(
                        serverURL: unwrappedSelf.serverURLTextField.stringValue,
                        repoURL: unwrappedSelf.repoURLTextField.stringValue,
                        localURL: url)
                }
                
                window.close()
                NSApp.stopModal(withCode: .OK)
            }
        }
    }
}

enum NewProjectOpenMethod {
    case join(serverURL: String, localURL: URL)
    case create(serverURL: String, repoURL: String, localURL: URL)
    
    var localURL: URL {
        switch self { case .join(_, let localURL), .create(_, _, let localURL):
            return localURL
        }
    }
    
    var serverURL: String {
        switch self { case .join(let serverURL, _), .create(let serverURL, _, _):
            return serverURL
        }
    }
    
    var repoURL: String? {
        switch self {
        case .create(_, let repoURL, _):
            return repoURL
        default:
            return nil
        }
    }
}
