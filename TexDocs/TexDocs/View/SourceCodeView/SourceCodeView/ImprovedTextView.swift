//
//  ImprovedTextView.swift
//  SourceCodeView
//
//  Created by Noah Peeters on 11.11.17.
//  Copyright © 2017 TexDocs. All rights reserved.
//

import Cocoa

/// Impoved Text view with helpfull helpers
class ImprovedTextView: NSTextView, NSTextViewDelegate, NSTextStorageDelegate {
    
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
    open func setUp() {
        self.delegate = self
    }

    // MARK: Helper

    var stringRange: NSRange {
        return NSRange(location: 0, length: textStorage!.length)
    }
    
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

    override func insertText(_ insertString: Any) {
        insertText(insertString, replacementRange: selectedRange())
    }

    override func insertText(_ string: Any, replacementRange: NSRange) {
        super.insertText(string, replacementRange: replacementRange)

        if let string = string as? String, let autocloseString = EditorAutoClose[string] {
            super.insertText(autocloseString, replacementRange: NSRange(location: NSMaxRange(replacementRange) + 1, length: 0))
            moveBackward(nil)
        }
    }

    override func deleteBackward(_ sender: Any?) {
        let leftStringStart = max(selectedRange().length > 0 ? selectedRange().location : (selectedRange().location - 1), 0)

        let leftString = nsString.substring(with: NSRange(location: leftStringStart, length: 1))

        super.deleteBackward(sender)

        if let closingString = EditorAutoClose[leftString], NSMaxRange(selectedRange()) < string.count {
            let rightString = nsString.substring(with: NSRange(location: NSMaxRange(selectedRange()), length: 1))
            if closingString == rightString {
                super.deleteForward(sender)
            }
        }
    }

    override func moveToLeftEndOfLine(_ sender: Any?) {
        guard let match = ImprovedTextView.lineBeginningSpaces.firstMatch(in: string, options: .anchored, range: currentLineRange),
            NSMaxRange(match.range) < selectedRange().location else {
                super.moveToLeftEndOfLine(sender)
                return
        }
        self.setSelectedRange(NSRange(location: NSMaxRange(match.range), length: 0))
    }

    override func keyDown(with event: NSEvent) {
        let string = event.charactersIgnoringModifiers
        let commandModifier = event.modifierFlags.contains(NSEvent.ModifierFlags.command)

        if commandModifier && string == "]" {
            incraseIndent()
        } else if commandModifier && string == "[" {
            decreaseIndent()
        } else {
            super.keyDown(with: event)
        }
    }

    open func incraseIndent() {
        updateIndent() {
            return (($0 / 4 + 1) * 4)
        }
    }

    open func decreaseIndent() {
        updateIndent() {
            return max((Int(ceil((Double($0) / Double(4))) - 1) * 4), 0)
        }
    }

    private func updateIndent(newIndentBlock: (Int) -> Int) {
        let initialSelection = selectedRange()

        var firstLineCharactersAdded = 0

        let totalCharactersAdded = lines(inRange: currentLineRange) { (_, lineRange) in
            let spaceMatch = ImprovedTextView.lineBeginningSpaces.firstMatch(in: string, options: [], range: lineRange)!
            let currentIndent = spaceMatch.range.length
            let targetIndent = newIndentBlock(currentIndent)
            insertText(String(repeating: " ", count: targetIndent), replacementRange: spaceMatch.range)

            let deltaCharacters = targetIndent - currentIndent
            if firstLineCharactersAdded == 0 {
                firstLineCharactersAdded = deltaCharacters
            }
            return targetIndent - currentIndent
        }

        setSelectedRange(NSRange(location: initialSelection.location + firstLineCharactersAdded, length: initialSelection.length + totalCharactersAdded - firstLineCharactersAdded))
    }

    private static let lineBeginningSpaces = try! NSRegularExpression(pattern: "^(\\s*)", options: .caseInsensitive)
    
    // MARK: Text did change

    fileprivate var userInitiated = true
    fileprivate var isContentReplace = false
    
    func textStorage(_ textStorage: NSTextStorage, didProcessEditing editedMask: NSTextStorageEditActions, range editedRange: NSRange, changeInLength delta: Int) {
        if editedMask.contains(NSTextStorageEditActions.editedCharacters) {
            let oldRange = NSRange(location: editedRange.location, length: editedRange.length - delta)
            textDidChange(oldRange: oldRange, newRange: editedRange, changeInLength: delta, byUser: userInitiated, isContentReplace: isContentReplace)
        }
    }

    func textViewDidChangeSelection(_ notification: Notification) {
        selectionDidChange(selection: selectedRange())
    }
    
    open func textDidChange(oldRange: NSRange, newRange: NSRange, changeInLength delta: Int, byUser: Bool, isContentReplace: Bool) {}
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

extension NSTextStorage {
    func replaceCharacters(in range: NSRange, with str: String, byUser: Bool) {
        let textViewDelegate = delegate as? ImprovedTextView
        textViewDelegate?.userInitiated = byUser
        replaceCharacters(in: range, with: str)
        textViewDelegate?.userInitiated = true
    }

    func replaceContent(with str: String) {
        let textViewDelegate = delegate as? ImprovedTextView
        textViewDelegate?.userInitiated = false
        textViewDelegate?.isContentReplace = true
        replaceCharacters(in: NSRange(location: 0, length: length), with: str)
        textViewDelegate?.isContentReplace = false
        textViewDelegate?.userInitiated = true
    }
}

private let EditorAutoClose = [
    "[": "]",
    "{": "}",
    "<": ">",
    "(": ")",
    "$": "$",
    "\"": "\"",
    "'": "'"
]
