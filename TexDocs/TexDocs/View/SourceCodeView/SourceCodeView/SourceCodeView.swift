//
//  SourceCodeView.swift
//  SourceCodeView
//
//  Created by Noah Peeters on 11.11.17.
//  Copyright © 2017 TexDocs. All rights reserved.
//

import Cocoa

class SourceCodeView: ImprovedTextView {
    
    // MARK: Variables
    
    /// The line number view on the left side.
    private var lineNumberRuler: SourceCodeRulerView!
    
    // MARK: View life cycle
    
    override func viewDidMoveToSuperview() {
        super.viewDidMoveToSuperview()
        setUpLineNumberRuler()
    }
    
    override func viewDidEndLiveResize() {
        super.viewDidEndLiveResize()
        lineNumberRuler.redrawLineNumbers()
    }
    
    // MARK: Line Number
    
    private func setUpLineNumberRuler() {
        guard let enclosingScrollView = enclosingScrollView else {
            return
        }

        let ruler = SourceCodeRulerView(sourceCodeView: self)
        lineNumberRuler = ruler
        enclosingScrollView.hasHorizontalRuler = false
        enclosingScrollView.hasVerticalRuler = true
        enclosingScrollView.rulersVisible = true
        enclosingScrollView.verticalRulerView = ruler
    }
    
    override func textDidChange(oldRange: NSRange, newRange: NSRange, changeInLength delta: Int, byUser: Bool) {
        super.textDidChange(oldRange: oldRange, newRange: newRange, changeInLength: delta, byUser: byUser)
        lineNumberRuler?.redrawLineNumbers()
        updateSourceCodeHighlighting()
    }
    
    func updateSourceCodeHighlighting() {
        
        
        
        let highlightingRules: [SourceCodeHighlightRule] = [
            SimpleHighlighter(pattern: "(\\\\\\w*)", colors: [.keyword]),
            SimpleHighlighter(pattern: "(%)(.*)$", colors: [.keyword, .comment]),
        ]
        
        
        textStorage?.addAttribute(NSAttributedStringKey.foregroundColor, value: ColorSchemeHandler.default.color(forKey: .text), range: rangeForUserParagraphAttributeChange)
        for rule in highlightingRules {
            rule.applyRule(to: self, range: rangeForUserParagraphAttributeChange)
        }
        
    }
}

protocol SourceCodeHighlightRule: class {
    func applyRule(to sourceCodeView: SourceCodeView, range: NSRange)
}
