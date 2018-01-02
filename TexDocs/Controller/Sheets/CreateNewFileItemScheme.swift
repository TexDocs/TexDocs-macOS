//
//  CreateNewFileScheme.swift
//  TexDocs
//
//  Created by Noah Peeters on 02.01.18.
//  Copyright © 2018 TexDocs. All rights reserved.
//

import Foundation

class CreateNewFileItemSheet: NSViewController {
    @IBOutlet weak var nameTextField: NSTextField!
    @IBOutlet weak var label: NSTextField!

    weak var delegate: CreateNewFileSheetDelegate?
    var superItem: FileSystemItem!
    var type: NewFileItemType = .file

    override func viewWillAppear() {
        label.stringValue = type.sheetTitle
    }

    @IBAction func closeButtonClicked(_ sender: Any) {
        delegate?.createNewFileItemSheet(self, createWithName: nameTextField.stringValue, ofType: type)
        dismiss(sender)
    }
}

enum NewFileItemType {
    case file
    case folder

    fileprivate var sheetTitle: String {
        switch self {
        case .file:
            return "Create new file"
        case .folder:
            return "Create new folder"
        }
    }
}

protocol CreateNewFileSheetDelegate: class {
    func createNewFileItemSheet(_ sheet: CreateNewFileItemSheet, createWithName name: String, ofType type: NewFileItemType)
}
