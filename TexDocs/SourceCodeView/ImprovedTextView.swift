//
//  ImprovedTextView.swift
//  SourceCodeView
//
//  Created by Noah Peeters on 11.11.17.
//  Copyright © 2017 TexDocs. All rights reserved.
//

import Cocoa

class ImprovedTextView: NSTextView, NSTextViewDelegate {
    
    
    //MARK: Init
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        setUp()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setUp()
    }
    
    private func setUp() {
        delegate = self
    }
    
    //MARK: Helper
    
    var nsString: NSString {
        return NSString(string: string)
    }
    
    var currentLineRange: NSRange {
        return nsString.lineRange(for: selectedRange())
    }
    
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
    
    //Mark: Delegates
    
    override func shouldChangeText(in affectedCharRange: NSRange, replacementString: String?) -> Bool {
        textDidChange(in: affectedCharRange, replacementString: replacementString ?? "")
        return super.shouldChangeText(in: affectedCharRange, replacementString: replacementString)
    }
    
    open func textDidChange(in range: NSRange, replacementString: String) {}
    
    
    //MARK: Remove format
    override func changeFont(_ sender: Any?) {}
    override func changeColor(_ sender: Any?) {}
}

