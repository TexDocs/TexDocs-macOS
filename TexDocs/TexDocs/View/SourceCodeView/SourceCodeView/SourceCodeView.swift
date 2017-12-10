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
    private var lineNumberRuler: SourceCodeRulerView?

    var languageDelegate: SourceCodeViewLanguageDelegate? {
        didSet {
            updateSourceCodeHighlighting(in: stringRange)
        }
    }

    weak var sourceCodeViewDelegate: SourceCodeViewDelegate?

    private(set) var rootStructureNode: CachedProperty<DocumentStructureNode?>?

    override func setUp() {
        super.setUp()

        rootStructureNode = CachedProperty(block: {
            return self.languageDelegate?.sourceCodeViewDocumentStructure(self)
        }, invalidationBlock: {
            self.sourceCodeViewDelegate?.sourceCodeViewStructureChanged(self)
        })
    }

    // MARK: View life cycle
    
    override func viewDidMoveToSuperview() {
        super.viewDidMoveToSuperview()
        setUpLineNumberRuler()
    }

    override func insertNewline(_ sender: Any?) {
        super.insertNewline(sender)

        if let path = rootStructureNode?.value?.path(toPosition: selectedRange().location - 1) {
            insertText(String(repeating: " ", count: (path.count - 1) * 4))

            if let closableDocumentStructureNode = path.last as? ClosableDocumentStructureNode, !closableDocumentStructureNode.closed {
                let selection = selectedRange()
                insertText("\n" + String(repeating: " ", count: (path.count - 2) * 4) + closableDocumentStructureNode.closeString)
                setSelectedRange(selection)
            }
        }
    }

    // MARK: Line Number

    override func updateRuler() {
        lineNumberRuler?.redrawLineNumbers()
    }
    
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
    
    override func textDidChange(oldRange: NSRange, newRange: NSRange, changeInLength delta: Int, byUser: Bool, isContentReplace: Bool) {
        super.textDidChange(oldRange: oldRange, newRange: newRange, changeInLength: delta, byUser: byUser, isContentReplace: isContentReplace)
        if !isContentReplace {
            updateSourceCodeHighlighting(in: newRange)
        }
        rootStructureNode?.invalidateCache()
    }
    
    func updateSourceCodeHighlighting(in editedRange: NSRange) {
        languageDelegate?.sourceCodeView(self, updateCodeHighlightingInRange: editedRange)
    }
}

protocol SourceCodeHighlightRule: class {
    func applyRule(to sourceCodeView: SourceCodeView, range: NSRange)
}

protocol SourceCodeViewDelegate: class {
    func sourceCodeViewStructureChanged(_ sourceCodeView: SourceCodeView)
}
