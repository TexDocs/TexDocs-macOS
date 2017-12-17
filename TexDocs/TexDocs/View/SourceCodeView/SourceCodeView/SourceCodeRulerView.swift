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
    
    private func drawLineNumber(text: NSAttributedString, atY y: CGFloat) {
        let drawWidth = text.size().width
        text.draw(at: NSPoint(x: ruleThickness - drawWidth - padding, y: y))
    }

    private func prepareDrawLineNumber(_ lineNumber: Int, attributes: [NSAttributedStringKey: Any]) -> NSAttributedString {
        return NSAttributedString(
            string: String(lineNumber),
            attributes: attributes
        )
    }

    private var visibleAnnotations: [(NSRect, RulerAnnotation)] = []

    private func draw(annotaion: RulerAnnotation, at lineFragmentRect: CGRect, relativeYTranslation: CGFloat) {
        let diameter = lineFragmentRect.height / 3 * 2
        let rect = NSRect(
            x: ruleThickness - diameter - padding,
            y: lineFragmentRect.minY + (lineFragmentRect.height - diameter) / 2 + relativeYTranslation,
            width: diameter,
            height: diameter)
        visibleAnnotations.append((rect, annotaion))
        let bezierPath = NSBezierPath(ovalIn: rect)
        #colorLiteral(red: 0.2745098174, green: 0.4862745106, blue: 0.1411764771, alpha: 1).setFill()
        bezierPath.fill()
    }
    
    override func drawHashMarksAndLabels(in rect: NSRect) {
        guard let textView = self.textView,
              let layoutManager = textView.layoutManager else {
            return
        }

        let annotations = textView.editableFileSystemItem?.annotations.value ?? []
        visibleAnnotations.removeAll(keepingCapacity: true)

        var attributes: [NSAttributedStringKey : Any] = [
            NSAttributedStringKey.foregroundColor: lineNumberColor
        ]
        attributes[NSAttributedStringKey.font] = UserDefaults.editorFont

        NSColor.white.setFill()
        rect.fill()
        
        let relativeYTranslation = convert(NSPoint.zero, from: textView).y
        
        // get visible range
        let visibleGlyphRange = layoutManager.glyphRange(forBoundingRect: textView.visibleRect, in: textView.textContainer!)
        let firstVisibleCharacterIndex = layoutManager.characterIndexForGlyph(at: visibleGlyphRange.location)
        
        // count line numbers in invisible range
        let invisibleRange = NSRange(location: 0, length: firstVisibleCharacterIndex)
        var lineNumber = NewLineRegex.numberOfMatches(in: textView.string, options: [], range: invisibleRange)

        var lineNumberTexts: [(NSAttributedString, CGFloat)] = []
        
        textView.lines(inRange: visibleGlyphRange) { (_, lineRange) in
            lineNumber += 1
            let lineFragmentRect = layoutManager.lineFragmentRect(forGlyphAt: lineRange.location, effectiveRange: nil, withoutAdditionalLayout: true)
            if let annotation = annotations.first(where: {lineRange.contains($0.lineNumber)}) {
                draw(annotaion: annotation, at: lineFragmentRect, relativeYTranslation: relativeYTranslation)
                return 0
            }
            lineNumberTexts.append((prepareDrawLineNumber(lineNumber, attributes: attributes), lineFragmentRect.origin.y + relativeYTranslation))
            return 0
        }

        if layoutManager.extraLineFragmentRect.height != 0 {
            lineNumber += 1
            let lineFragmentRect = layoutManager.extraLineFragmentRect
            lineNumberTexts.append((prepareDrawLineNumber(lineNumber, attributes: attributes), lineFragmentRect.origin.y + relativeYTranslation))
        }

        let maxWidth = lineNumberTexts.reduce(0) { (oldMaxWidth, lineNumberText) in
            return max(oldMaxWidth, lineNumberText.0.size().width)
        }
        ruleThickness = max(maxWidth, 20) + 2 * padding

        lineNumberTexts.forEach { (string, y) in
            drawLineNumber(text: string, atY: y)
        }
    }

    override func mouseDown(with event: NSEvent) {
        let convertedPoint = self.convert(event.locationInWindow, from: event.window?.contentView)

        if let data = visibleAnnotations.first(where: { $0.0.contains(convertedPoint) }) {
            textView?.rulerViewAnnotationClicked(annotation: data.1)
        }
    }
    
    func redrawLineNumbers() {
        needsDisplay = true
    }
}
