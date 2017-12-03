//
//  CollaborationSourceCodeView.swift
//  SourceCodeView
//
//  Created by Noah Peeters on 11.11.17.
//  Copyright © 2017 TexDocs. All rights reserved.
//

import Foundation

class CollaborationSourceCodeView: SourceCodeView {

    weak var collaborationDelegate: CollaborationSourceCodeViewDelegate?
    private weak var openedFile: EditableFileSystemItem? {
        didSet {
            handleFileOpen(openedFile, oldFile: oldValue)
        }
    }
    
    override func setUp() {
        super.setUp()
        openFile(nil)
    }
    
    func openFile(_ file: EditableFileSystemItem?) {
        openedFile = file
    }
    
    private func handleFileOpen(_ newFile: EditableFileSystemItem?, oldFile: EditableFileSystemItem?) {
        if let oldFile = oldFile {
            saveContent(to: oldFile)
        }
        
        loadContent(from: newFile)
    }
    
    func loadContent(from fileItem: EditableFileSystemItem? = nil) {
        guard let fileItem = fileItem ?? openedFile else {
            isEditable = false
            replaceContent(with: "")
            return
        }
        
        replaceContent(with: fileItem.text)
        self.isEditable = true
    }
    
    func saveContent(to fileItem: EditableFileSystemItem? = nil) {
        (fileItem ?? openedFile)?.text = string
    }
    
    func collaborationCursorsDidChange() {
        setNeedsDisplay(editorBounds)
    }
    
    private var collaborationCursors: [CollaborationCursor] {
        return collaborationDelegate?.collaborationCursors(for: self) ?? []
    }
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        guard let layoutManager = self.layoutManager, let textContainer = self.textContainer else {
            return
        }
        
        for cursor in collaborationCursors {
    
            let startPositionRange = NSRange(location: cursor.range.location, length: 0)
            let startPositionRect = layoutManager.boundingRect(forGlyphRange: startPositionRange, in: textContainer)
            let startPosition = startPositionRect.origin
            let cursorHeight = startPositionRect.size.height
            let cursorSize = CGSize(width: 1, height: cursorHeight)
            
            if cursor.range.length == 0 {
                // draw cursor
                cursor.color.setFill()
                NSRect(origin: startPosition, size: cursorSize).fill()
            } else {
                // draw selection
                let endPositionRange = NSRange(location: NSMaxRange(cursor.range), length: 0)
                let endPositionRect = layoutManager.boundingRect(forGlyphRange: endPositionRange, in: textContainer)
                let endPosition = endPositionRect.origin
                
                cursor.color.withAlphaComponent(0.3).setFill()
                
                if startPosition.y == endPosition.y {
                    NSRect(x: startPosition.x, y: startPosition.y, width: endPosition.x - startPosition.x, height: cursorHeight).fill()
                } else {
                    drawSelectionToEndOfLine(from: startPosition, cursorHeight: cursorHeight)
                    drawSelectionToBeginningOfLine(from: endPosition, cursorHeight: cursorHeight)
                    fillLines(between: startPositionRect.maxY, and: endPositionRect.minY)
                }
            }
        }
    }
    
    private var editorBounds: CGRect {
        return bounds.insetBy(dx: 5, dy: 0)
    }
    
    private func drawSelectionToEndOfLine(from origin: CGPoint, cursorHeight: CGFloat) {
        NSRect(origin: origin, size: CGSize(width: editorBounds.maxX - origin.x, height: cursorHeight)).fill()
    }
    
    private func drawSelectionToBeginningOfLine(from origin: CGPoint, cursorHeight: CGFloat) {
        NSRect(x: editorBounds.minX, y: origin.y, width: origin.x - editorBounds.minX, height: cursorHeight).fill()
    }
    
    private func fillLines(between minY: CGFloat, and maxY: CGFloat) {
        NSRect(x: editorBounds.minX, y: minY, width: editorBounds.width, height: maxY - minY).fill()
    }
    
    override func textDidChange(oldRange: NSRange, newRange: NSRange, changeInLength delta: Int, byUser: Bool) {
        super.textDidChange(oldRange: oldRange, newRange: newRange, changeInLength: delta, byUser: byUser)
        collaborationDelegate?.textDidChange(oldRange: oldRange, newRange: newRange, changeInLength: delta, byUser: byUser, to: nsString.substring(with: newRange))
    }
    
    override func selectionDidChange(selection: NSRange) {
        super.selectionDidChange(selection: selection)
        collaborationDelegate?.userSelectionDidChange(selection)
    }
}

protocol CollaborationSourceCodeViewDelegate: class {
    func textDidChange(oldRange: NSRange, newRange: NSRange, changeInLength delta: Int, byUser: Bool, to newString: String)
    func collaborationCursors(for editor: CollaborationSourceCodeView) -> [CollaborationCursor]
    func userSelectionDidChange(_ newSelection: NSRange)
}
