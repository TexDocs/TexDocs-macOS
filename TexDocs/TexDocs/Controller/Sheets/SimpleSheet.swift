//
//  SimpleSheet.swift
//  TexDocs
//
//  Created by Noah Peeters on 15.11.17.
//  Copyright © 2017 TexDocs. All rights reserved.
//

import Cocoa

class SimpleSheet: NSViewController {
    @IBOutlet weak var progressBar: NSProgressIndicator? { didSet { updateProgressBar(value: progressValue, enableButton: enableButton) }}
    @IBOutlet weak var statusLabel: NSTextField? { didSet { updateLabel(text: labelText) }}
    @IBOutlet weak var button: NSButton? { didSet { updateButton(title: buttonTitle) }}
    
    weak var editorWindowController: EditorViewController!
    
    @IBAction func buttonPressed(_ sender: NSButton) {
        action?()
    }
    
    private var buttonTitle: String? = nil
    private var labelText: String? = nil
    private var progressValue: Double? = nil
    private var enableButton: Bool = false
    
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
    }

    func updateLabel(text: String?) {
        self.labelText = text
        guard let text = text else {
            statusLabel?.isHidden = true
            return
        }
        
        statusLabel?.stringValue = text
        statusLabel?.isHidden = false
    }
    
    func updateProgressBar(value: Double?, enableButton: Bool) {
        self.progressValue = value
        self.enableButton = enableButton
        button?.isEnabled = enableButton
        
        guard let value = value else {
            progressBar?.isIndeterminate = true
            progressBar?.startAnimation(self)
            return
        }
        
        progressBar?.isIndeterminate = false
        progressBar?.doubleValue = value
    }
}
