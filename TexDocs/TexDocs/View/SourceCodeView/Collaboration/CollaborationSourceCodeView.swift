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
    
    override func viewDidMoveToSuperview() {
        super.viewDidMoveToSuperview()
        
//        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
//            let storyboard = NSStoryboard(name: NSStoryboard.Name("Main"), bundle: nil)
//            let windowController = storyboard.instantiateController(withIdentifier: NSStoryboard.SceneIdentifier("LoadingWindowController")) as! NSWindowController
//
//            self.window?.beginSheet(windowController.window!, completionHandler: nil)
//            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
//                self.window?.endSheet(windowController.window!)
//            }
//        }
        self.replaceString(in: NSMakeRange(0, 0), replacementString: "12345678901234567890")
    }
    
//    override func textDidChange(in range: NSRange, replacementString: String, byUser: Bool) {
//        super.textDidChange(in: range, replacementString: replacementString, byUser: byUser)
//        collaborationCursors = collaborationCursors.map { cursor in
//
//            let deltaCharacters = replacementString.count - range.length
//            let cursorMax = NSMaxRange(cursor.range)
//            let changeMax = NSMaxRange(range)
//            let newChangeMax = changeMax + deltaCharacters
//
//            if cursor.range.location <= range.location {       // cursor starts in front of the change
//                if cursorMax <= range.location {               // cursor ends in front of the change
//                    return cursor
//                } else if range.contains(cursorMax) {          // cursor ends in change
//                    return cursor.withLenght(range.location - cursor.range.location)
//                } else {                                       // cursor ends behind change
//                    return cursor.withLenght(cursor.range.length + deltaCharacters)
//                }
//            } else if range.contains(cursor.range.location) {  // cursor starts in change
//                if range.contains(cursorMax) {                 // cursor ends in change
//                    return cursor.with(NSRange(location: newChangeMax, length: 0))
//                } else {                                       // cursor ends after change
//                    return cursor.with(NSRange(location: newChangeMax, length: cursorMax - changeMax))
//                }
//            } else {                                           // cursor starts and ends after change
//                return cursor.withDeltaLocation(deltaCharacters)
//            }
//        }
//    }
}

protocol CollaborationSourceCodeViewDelegate: class {
    func textDidChange(in range: NSRange, replacementString: String, byUser: Bool)
    func collaborationCursors(for editor: CollaborationSourceCodeView) -> [CollaborationCursor]
}
