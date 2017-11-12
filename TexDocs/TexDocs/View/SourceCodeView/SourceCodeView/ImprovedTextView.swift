//
//  ImprovedTextView.swift
//  SourceCodeView
//
//  Created by Noah Peeters on 11.11.17.
//  Copyright © 2017 TexDocs. All rights reserved.
//

import Cocoa

/// Impoved Text view with helpfull helpers
class ImprovedTextView: NSTextView, NSTextStorageDelegate {
    
    // MARK: Init
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        setUp()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setUp()
    }
    
    /// Some basic setups
    private func setUp() {
        self.textStorage?.delegate = self
    }
    
    // MARK: Helper
    
    /// NSString version of string property
    var nsString: NSString {
        return NSString(string: string)
    }
    
    /// The Range of the current line.
    var currentLineRange: NSRange {
        return nsString.lineRange(for: selectedRange())
    }
    
    /// The string of the current line
    var currentLine: String {
        return nsString.substring(with: currentLineRange)
    }
    
    @discardableResult func lines(inRange range: NSRange, block: (Int, NSRange) -> Int) -> Int {
        var glyphIndexForStringLine = range.location
        let endIndex = NSMaxRange(range)
        var relativeLineNumber = 0
        var totalCharactersAdded = 0
        
        while glyphIndexForStringLine < endIndex + totalCharactersAdded {
            // get line range
            let stringIndex = layoutManager!.characterIndexForGlyph(at: glyphIndexForStringLine)
            let lineRange = nsString.lineRange(for: NSRange(location: stringIndex, length: 0))
            
            let lineChange = block(relativeLineNumber, lineRange)
            
            totalCharactersAdded += lineChange
            glyphIndexForStringLine = NSMaxRange(lineRange) + lineChange
            relativeLineNumber += 1
        }
        return totalCharactersAdded
    }
    
    // Mark: Text did change

    private var userInitiated: Bool = true
    
    func textStorage(_ textStorage: NSTextStorage, didProcessEditing editedMask: NSTextStorageEditActions, range editedRange: NSRange, changeInLength delta: Int) {
        if editedMask.contains(NSTextStorageEditActions.editedCharacters) {
            let oldRange = NSRange(location: editedRange.location, length: editedRange.length - delta)
            print(oldRange, editedRange, delta, userInitiated)
            textDidChange(oldRange: oldRange, newRange: editedRange, changeInLength: delta, byUser: userInitiated)
        }
    }
    
    func replaceString(in range: NSRange, replacementString: String, byUser: Bool = false) {
        userInitiated = false
        textStorage?.replaceCharacters(in: range, with: replacementString)
        userInitiated = true
    }
    
    func textViewDidChangeSelection(_ notification: Notification) {
        selectionDidChange(selection: selectedRange())
    }
    
    open func textDidChange(oldRange: NSRange, newRange: NSRange, changeInLength delta: Int, byUser: Bool) {}
    open func selectionDidChange(selection: NSRange) {}
    
    // MARK: Remove format
    override func changeFont(_ sender: Any?) {}
    override func setFont(_ font: NSFont, range: NSRange) {}
    override func changeColor(_ sender: Any?) {}
    override func setTextColor(_ color: NSColor?, range: NSRange) {}
    override func pasteFont(_ sender: Any?) {}
    override func pasteRuler(_ sender: Any?) {}
    override func alignLeft(_ sender: Any?) {}
    override func alignCenter(_ sender: Any?) {}
    override func alignRight(_ sender: Any?) {}
    override func underline(_ sender: Any?) {}
}
