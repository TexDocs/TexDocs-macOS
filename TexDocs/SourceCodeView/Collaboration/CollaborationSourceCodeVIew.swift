//
//  CollaborationSourceCodeVIew.swift
//  SourceCodeView
//
//  Created by Noah Peeters on 11.11.17.
//  Copyright © 2017 TexDocs. All rights reserved.
//

import Foundation

class CollaborationSourceCodeView: SourceCodeView {

    /// List of all cursors
    var collaborationCursors: [CollaborationCursor] = [] {
        didSet {
            setNeedsDisplay(editorBounds)
        }
    }
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        guard let layoutManager = self.layoutManager, let textContainer = self.textContainer else {
            return
        }
        
        for cursor in collaborationCursors {
    
            let startPositionRange = NSRange(location: cursor.startPosition, length: 0)
            let startPositionRect = layoutManager.boundingRect(forGlyphRange: startPositionRange, in: textContainer)
            let startPosition = startPositionRect.origin
            let cursorHeight = startPositionRect.size.height
            let cursorSize = CGSize(width: 1, height: cursorHeight)
            
            // draw cursor
            cursor.color.setFill()
            NSRect(origin: startPosition, size: cursorSize).fill()
            
            // draw selection
            if cursor.length != 0 {
                let endPositionRange = NSRange(location: cursor.startPosition + cursor.length, length: 0)
                let endPositionRect = layoutManager.boundingRect(forGlyphRange: endPositionRange, in: textContainer)
                let endPosition = endPositionRect.origin
                
                cursor.color.withAlphaComponent(0.3).setFill()
                
                if startPosition.y == endPosition.y {
                    NSRect(x: startPosition.x, y: startPosition.y, width: endPosition.x - startPosition.x, height: cursorHeight).fill()
                } else if startPosition.y < endPosition.y {
                    drawSelectionToEndOfLine(from: startPosition, cursorHeight: cursorHeight)
                    drawSelectionToBeginningOfLine(from: endPosition, cursorHeight: cursorHeight)
                    fillLines(between: startPositionRect.maxY, and: endPositionRect.minY)
                } else {
                    drawSelectionToEndOfLine(from: endPosition, cursorHeight: cursorHeight)
                    drawSelectionToBeginningOfLine(from: startPosition, cursorHeight: cursorHeight)
                    fillLines(between: endPositionRect.maxY, and: startPositionRect.minY)
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
}


struct CollaborationCursor {
    let startPosition: Int
    let length: Int
    let color: NSColor
}
