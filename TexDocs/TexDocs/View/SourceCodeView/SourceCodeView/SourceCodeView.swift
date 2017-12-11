//
//  SourceCodeView.swift
//  SourceCodeView
//
//  Created by Noah Peeters on 11.11.17.
//  Copyright © 2017 TexDocs. All rights reserved.
//

import Cocoa

class SourceCodeView: ImprovedTextView, EditableFileSystemItemDelegate {
    
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

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(updateTheme),
            name: UserDefaults.themeName.notificationKey,
            object: nil)
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

    @objc func updateTheme() {
        updateSourceCodeHighlighting(in: stringRange)
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
    
    func textDidChange(oldRange: NSRange, newRange: NSRange, changeInLength delta: Int, byUser: Bool, isContentReplace: Bool) {
        if !isContentReplace {
            updateSourceCodeHighlighting(in: newRange)
        }
        rootStructureNode?.invalidateCache()
    }
    
    func updateSourceCodeHighlighting(in editedRange: NSRange) {
        languageDelegate?.sourceCodeView(self, updateCodeHighlightingInRange: editedRange)
    }

    //MARK: Completion


    private var completionOpened = false
    private var languageCompletions: LanguageCompletions?

    override func keyDown(with event: NSEvent) {
        if event.characters?.first?.isControllCharacter ?? true {
            completionOpened = false
        }

        let string = event.charactersIgnoringModifiers

        let controlModifier = event.modifierFlags.contains(NSEvent.ModifierFlags.control)

        if controlModifier && string == " " {
            completionOpened = true
        } else if string == "\\" {
            super.keyDown(with: event)
            completionOpened = true
        } else {
            super.keyDown(with: event)
        }

        if completionOpened {
            complete(self)
        }
    }

    override func complete(_ sender: Any?) {
        languageDelegate?.sourceCodeView(self, completionsForLocation: selectedRange().location) {
            self.languageCompletions = $0
            super.complete(sender)
        }
    }

    override var rangeForUserCompletion: NSRange {
        return languageCompletions?.rangeForUserCompletion ?? super.rangeForUserCompletion
    }

    func textView(_ textView: NSTextView, completions words: [String], forPartialWordRange charRange: NSRange, indexOfSelectedItem index: UnsafeMutablePointer<Int>?) -> [String] {
        return languageCompletions?.completionProposals ?? words
    }

    override func insertCompletion(_ identifier: String, forPartialWordRange charRange: NSRange, movement: Int, isFinal flag: Bool) {
        let identifierComponents = identifier.components(separatedBy: ":")

        guard let languageCompletion = languageCompletions, identifierComponents.count > 1, let index = Int(identifierComponents[0]) else {
            super.insertCompletion(identifier, forPartialWordRange: charRange, movement: movement, isFinal: flag)
            return
        }

        let completion = languageCompletion.words[index]

        switch movement {
        case NSReturnTextMovement, NSTabTextMovement:
            completionOpened = false
            let insertString = completion.completionString
            super.insertCompletion(insertString, forPartialWordRange: charRange, movement: movement, isFinal: flag)
        case NSRightTextMovement, NSLeftTextMovement, NSCancelTextMovement:
            completionOpened = false
        default:
            break
        }
    }
}

protocol SourceCodeHighlightRule: class {
    func applyRule(to sourceCodeView: SourceCodeView, range: NSRange)
}

protocol SourceCodeViewDelegate: class {
    func sourceCodeViewStructureChanged(_ sourceCodeView: SourceCodeView)
}

extension Character {
    fileprivate var isControllCharacter: Bool {
        guard let code = String(self).utf16.first else {
            return false
        }

        return code <= 31 || [127, 63272, 63232, 63233, 63234, 63235].index(of: code) != nil
    }
}
