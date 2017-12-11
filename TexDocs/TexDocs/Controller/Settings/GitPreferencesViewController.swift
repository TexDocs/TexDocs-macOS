//
//  GitPreferencesViewController.swift
//  TexDocs
//
//  Created by Noah Peeters on 11.12.17.
//  Copyright © 2017 TexDocs. All rights reserved.
//

import Cocoa
import LabeledTextField

class GitPreferencesViewController: NSViewController, CCNPreferencesWindowControllerProtocol {
    func preferenceIdentifier() -> String! {
        return "gitPreferences"
    }

    func preferenceTitle() -> String! {
        return NSLocalizedString("TD_PREFERENCS_TITLE_GIT", comment: "Git preferences title")
    }

    func preferenceIcon() -> NSImage! {
        return NSImage(named: NSImage.Name(rawValue: "GitIcon"))
    }

    @IBOutlet weak var publicKeyTextField: LabeledTextField!
    @IBOutlet weak var privateKeyTextField: LabeledTextField!
    @IBOutlet weak var nameTextField: LabeledTextField!
    @IBOutlet weak var emailTextField: LabeledTextField!

    override func viewDidLoad() {
        publicKeyTextField.value = UserDefaults.publicKeyPath.value
        privateKeyTextField.value = UserDefaults.privateKeyPath.value
        nameTextField.value = UserDefaults.gitName.value
        emailTextField.value = UserDefaults.gitEMail.value
    }

    @IBAction func publicKeyChanged(_ sender: Any) {
        UserDefaults.publicKeyPath.value = publicKeyTextField.value
    }

    @IBAction func privateKeyChanged(_ sender: Any) {
        UserDefaults.privateKeyPath.value = privateKeyTextField.value
    }

    @IBAction func nameChanged(_ sender: Any) {
        UserDefaults.gitName.value = nameTextField.value
    }
    
    @IBAction func emailChanged(_ sender: Any) {
        UserDefaults.gitEMail.value = emailTextField.value
    }
}
