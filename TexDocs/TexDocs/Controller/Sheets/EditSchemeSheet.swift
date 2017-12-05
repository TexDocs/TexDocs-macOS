//
//  EditSchemeSheet.swift
//  TexDocs
//
//  Created by Noah Peeters on 04.12.17.
//  Copyright © 2017 TexDocs. All rights reserved.
//

import Cocoa

class EditSchemeSheet: NSViewController {
    @IBOutlet weak var nameTextField: NSTextField!
    @IBOutlet weak var fileTextField: NSTextField!

    weak var delegate: EditSchemeSheetDelegate?
    var scheme: DocumentData.Scheme!

    override func viewWillAppear() {
        nameTextField.stringValue = scheme.name
        fileTextField.stringValue = scheme.path
    }

    @IBAction func closeButtonClicked(_ sender: Any) {
        scheme.name = nameTextField.stringValue
        scheme.path = fileTextField.stringValue
        delegate?.schemeUpdated()
        dismiss(sender)
    }
}

protocol EditSchemeSheetDelegate: class {
    func schemeUpdated()
}
