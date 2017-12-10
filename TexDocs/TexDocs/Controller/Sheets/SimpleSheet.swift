//
//  SimpleSheet.swift
//  TexDocs
//
//  Created by Noah Peeters on 15.11.17.
//  Copyright © 2017 TexDocs. All rights reserved.
//

import Cocoa

class SimpleSheet: NSViewController {
    @IBOutlet weak var progressBar: NSProgressIndicator? { didSet { updateProgressBar(value: progressValue) }}
    @IBOutlet weak var statusLabel: NSTextField? { didSet { updateLabel(text: labelText) }}
    @IBOutlet weak var button: NSButton? { didSet { updateButton(title: buttonTitle) }}

    @IBAction func buttonPressed(_ sender: NSButton) {
        action?()
    }
    
    private var buttonTitle: String? = nil
    private var labelText: String = ""
    private var progressValue: ProgressBarValue = .indeterminate
    
    private var action: (() -> Void)?
    
    func updateButton(title: String?, action: (() -> Void)? = nil) {
        self.buttonTitle = title
        self.action = action
        
        guard let title = title else {
            button?.isHidden = true
            return
        }
        
        button?.title = title
        button?.isHidden = false
        if action != nil {
            button?.becomeFirstResponder()
        }
    }

    func updateLabel(text: String) {
        self.labelText = text
        statusLabel?.stringValue = text
    }
    
    func updateProgressBar(value: ProgressBarValue) {
        self.progressValue = value
        progressBar?.isHidden = false
        
        switch value {
        case .hidden:
            progressBar?.isHidden = true
        case .indeterminate:
            progressBar?.isIndeterminate = true
            progressBar?.startAnimation(self)
        case .value(let progress):
            progressBar?.isIndeterminate = false
            progressBar?.doubleValue = progress
        }
    }
}

enum ProgressBarValue {
    case hidden
    case indeterminate
    case value(Double)
}
