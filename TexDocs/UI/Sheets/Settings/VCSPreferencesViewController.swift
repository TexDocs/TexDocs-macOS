//
//  VCSPreferencesViewController.swift
//  TexDocs
//
//  Created by Noah Peeters on 11.12.17.
//  Copyright © 2017 TexDocs. All rights reserved.
//

import Cocoa
import UIElementsKit

class VCSPreferencesViewController: NSViewController, CCNPreferencesWindowControllerProtocol {
    func preferenceIdentifier() -> String! {
        return "vcsPreferences"
    }

    func preferenceTitle() -> String! {
        return NSLocalizedString("TD_PREFERENCS_TITLE_VCS", comment: "VCS preferences title")
    }

    func preferenceIcon() -> NSImage! {
        return NSImage(named: NSImage.Name(rawValue: "VCSIcon"))
    }

    @IBOutlet weak var nameTextField: LabeledTextField!

    override func viewDidLoad() {
        nameTextField.value = UserDefaults.vcsName.value
    }
    @IBAction func nameChanged(_ sender: Any) {
        UserDefaults.vcsName.value = nameTextField.value
    }
}
