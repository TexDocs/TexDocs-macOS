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
    var attributes = CachedProperty<[NSAttributedStringKey: Any]>(block: {
        var attributes: [NSAttributedStringKey: Any] = [
            NSAttributedStringKey.foregroundColor: #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1)
        ]
        attributes[NSAttributedStringKey.font] = UserDefaults.editorFont
        return attributes
    })

    // MARK: Init

    init(sourceCodeView: SourceCodeView) {
        super.init(scrollView: sourceCodeView.enclosingScrollView!, orientation: .verticalRuler)
        self.clientView = sourceCodeView
    }

    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func lineNumberText(forLineNumber lineNumber: Int) -> NSAttributedString {
        return NSAttributedString(
            string: String(lineNumber),
            attributes: attributes.value
        )
    }

    private func drawLineNumber(_ lineNumber: Int, atYPosition yPosition: CGFloat) {
        let text = lineNumberText(forLineNumber: lineNumber)

        let drawWidth = text.size().width
        text.draw(at: NSPoint(x: ruleThickness - drawWidth - padding, y: yPosition))
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
        annotaion.type.color.setFill()
        bezierPath.fill()
    }

    override func drawHashMarksAndLabels(in rect: NSRect) {
        guard let textView = self.textView,
              let layoutManager = textView.layoutManager else {
            return
        }

        attributes.invalidateCache()

        let highestLineNumber = 1 + newLineRegex.numberOfMatches(
            in: textView.string,
            options: [],
            range: NSRange(textView.string.startIndex..<textView.string.endIndex, in: textView.string))
        ruleThickness = max(lineNumberText(forLineNumber: highestLineNumber).size().width + 2 * padding, 30)

        let annotations: [RulerAnnotation] = textView.editableFileSystemItem?.annotations ?? []
        visibleAnnotations.removeAll(keepingCapacity: true)

        // draw background color
        NSColor.white.setFill()
        rect.fill()

        let relativeYTranslation = convert(NSPoint.zero, from: textView).y

        // get visible range
        let visibleGlyphRange = layoutManager.glyphRange(forBoundingRect: textView.visibleRect, in: textView.textContainer!)
        let firstVisibleCharacterIndex = layoutManager.characterIndexForGlyph(at: visibleGlyphRange.location)

        // count line numbers in invisible range
        let invisibleRange = NSRange(location: 0, length: firstVisibleCharacterIndex)
        var lineNumber = newLineRegex.numberOfMatches(in: textView.string, options: [], range: invisibleRange)

        textView.lines(inRange: visibleGlyphRange) { (_, lineRange) in
            lineNumber += 1
            let lineFragmentRect = layoutManager.lineFragmentRect(forGlyphAt: lineRange.location, effectiveRange: nil, withoutAdditionalLayout: true)
            if let annotation = annotations.first(where: {lineRange.contains($0.lineNumber)}) {
                draw(annotaion: annotation, at: lineFragmentRect, relativeYTranslation: relativeYTranslation)
                return 0
            }
            drawLineNumber(lineNumber, atYPosition: lineFragmentRect.origin.y + relativeYTranslation)
            return 0
        }

        if layoutManager.extraLineFragmentRect.height != 0 {
            lineNumber += 1
            let lineFragmentRect = layoutManager.extraLineFragmentRect
            drawLineNumber(lineNumber, atYPosition: lineFragmentRect.origin.y + relativeYTranslation)
        }
    }

    override func mouseDown(with event: NSEvent) {
        let convertedPoint = self.convert(event.locationInWindow, from: event.window?.contentView)

        if let data = visibleAnnotations.first(where: { $0.0.contains(convertedPoint) }) {
            textView?.rulerViewAnnotationClicked(annotation: data.1, inRuler: self, rect: data.0)
        }
    }

    func redrawLineNumbers() {
        needsDisplay = true
    }
}
