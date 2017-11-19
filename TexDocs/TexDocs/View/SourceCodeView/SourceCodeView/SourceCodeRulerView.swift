//
//  SourceCodeRulerView.swift
//  SourceCodeView
//
//  Created by Noah Peeters on 11.11.17.
//  Copyright © 2017 TexDocs. All rights reserved.
//

import Cocoa

/// Ruler view for line numbers
class SourceCodeRulerView: NSRulerView {
    
    // MARK: Variables
    
    override var requiredThickness: CGFloat {
        return ruleThickness
    }
    
    /// Client source code view
    private weak var textView: SourceCodeView? {
        return clientView as? SourceCodeView
    }
    
    // MARK: Config
    
    var padding: CGFloat = 5
    var lineNumberColor: NSColor = .gray
    
    // MARK: Init
    
    init(sourceCodeView: SourceCodeView) {
        super.init(scrollView: sourceCodeView.enclosingScrollView!, orientation: .verticalRuler)
        self.clientView = sourceCodeView
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func drawLineNumber(_ lineNumber: Int, atY y: CGFloat) -> CGFloat {
        let text = NSAttributedString(
            string: String(lineNumber),
            attributes: [NSAttributedStringKey.foregroundColor: lineNumberColor]
        )
        
        let drawWidth = text.size().width
        text.draw(at: NSPoint(x: ruleThickness - drawWidth - padding, y: y))
        
        return drawWidth
    }
    
    override func drawHashMarksAndLabels(in rect: NSRect) {
        guard let textView = self.textView,
              let layoutManager = textView.layoutManager else {
            return
        }
        
        let relativeYTranslation = convert(NSPoint.zero, from: textView).y
        
        // get visible range
        let visibleGlyphRange = layoutManager.glyphRange(forBoundingRect: textView.visibleRect, in: textView.textContainer!)
        let firstVisibleCharacterIndex = layoutManager.characterIndexForGlyph(at: visibleGlyphRange.location)
        
        // count line numbers in invisible range
        let invisibleRange = NSRange(location: 0, length: firstVisibleCharacterIndex)
        var lineNumber = NewLineRegex.numberOfMatches(in: textView.string, options: [], range: invisibleRange)
        var maxWith: CGFloat = 0
        
        textView.lines(inRange: visibleGlyphRange) { (_, lineRange) in
            lineNumber += 1
            var effectiveRange = NSRange(location: 0, length: 0)
            let lineYPosition = layoutManager.lineFragmentRect(forGlyphAt: lineRange.location, effectiveRange: &effectiveRange, withoutAdditionalLayout: true).origin.y
            maxWith = max(drawLineNumber(lineNumber, atY: lineYPosition + relativeYTranslation), maxWith)
            return 0
        }

        if layoutManager.extraLineFragmentRect.height != 0 {
            lineNumber += 1
            maxWith = max(drawLineNumber(lineNumber, atY: layoutManager.extraLineFragmentRect.origin.y + relativeYTranslation), maxWith)
        }

        self.ruleThickness = max(maxWith, 20) + 2 * padding
    }
    
    func redrawLineNumbers() {
        needsDisplay = true
    }
}
