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
    @IBOutlet weak var createOfflineRadioButton: NSButton!
    @IBOutlet weak var saveButton: NSButton!
    @IBOutlet weak var serverURLTextField: NSTextField!
    @IBOutlet weak var repositoryURLTextField: NSTextField!
    @IBOutlet weak var warningStackView: NSStackView!
    
    
    private(set) var method: NewProjectOpenMethod?
    private(set) var localURL: URL?
    
    override func viewDidLoad() {
        repositoryURLTextField.isHidden = true
        warningStackView.isHidden = true
    }
    
    override func viewDidDisappear() {
        super.viewDidDisappear()
        NSApp.stopModal()
    }
    
    @IBAction func joinRadioButtonPressed(_ sender: NSButton) {
        serverURLTextField.isHidden = false
        repositoryURLTextField.isHidden = true
        saveButton.title = NSLocalizedString("TD_BUTTON_JOIN", comment: "Button to join an existing project.")
        createRadioButton.state = .off
        createOfflineRadioButton.state = .off
        inputChanged()
    }
    
    @IBAction func createRadioButtonPressed(_ sender: NSButton) {
        serverURLTextField.isHidden = false
        repositoryURLTextField.isHidden = false
        saveButton.title = NSLocalizedString("TD_BUTTON_CREATE", comment: "Button to create a new project.")
        joinRadioButton.state = .off
        createOfflineRadioButton.state = .off
        inputChanged()
    }
    
    @IBAction func createOfflineRadioButtonPressed(_ sender: NSButton) {
        serverURLTextField.isHidden = true
        repositoryURLTextField.isHidden = true
        saveButton.title = NSLocalizedString("TD_BUTTON_CREATE_OFFLINE", comment: "Button to create a new offline project.")
        joinRadioButton.state = .off
        createRadioButton.state = .off
        inputChanged()
    }
    
    @IBAction func userEditedURL(_ sender: NSTextField) {
        inputChanged()
    }
    
    private func inputChanged() {
        warningStackView.isHidden = true
    }
    
    private func getServerURL() -> URL? {
        return URL(string: serverURLTextField.stringValue)
    }
    
    private func getRepositoryURL() -> URL? {
        return URL(string: repositoryURLTextField.stringValue)
    }
    
    private func getNewProjectMethod() -> NewProjectOpenMethod? {
        if createOfflineRadioButton.state == .on {
            return .offline
        } else if joinRadioButton.state == .on {
            guard let serverURL = getServerURL() else { return nil }
            return .join(serverURL: serverURL)
        } else {
            guard let serverURL = getServerURL(), let repositoryURL = getRepositoryURL() else { return nil }
            return .create(serverURL: serverURL, repositoryURL: repositoryURL)
        }
    }
    
    @IBAction func cancel(_ sender: Any) {
        view.window?.close()
        NSApp.stopModal(withCode: .cancel)
    }
    
    @IBAction func save(_ sender: Any) {
        guard let window = view.window else {
            return
        }
        
        guard let method = getNewProjectMethod() else {
            warningStackView.isHidden = false
            return
        }
        
        self.method = method
        
        let savePanel = NSSavePanel()
        
        savePanel.beginSheetModal(for: window) { [weak self] response in
            if response == .OK, let url = savePanel.url {
                self?.localURL = url
                window.close()
                NSApp.stopModal(withCode: .OK)
            }
        }
    }
}

