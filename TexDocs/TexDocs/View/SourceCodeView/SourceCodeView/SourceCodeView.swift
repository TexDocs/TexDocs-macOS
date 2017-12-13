//
//  SourceCodeView.swift
//  SourceCodeView
//
//  Created by Noah Peeters on 11.11.17.
//  Copyright © 2017 TexDocs. All rights reserved.
//

import Cocoa

class SourceCodeView: ImprovedTextView, EditableFileSystemItemDelegate, CompletionViewControllerDelegate {
    
    // MARK: Variables
    
    /// The line number view on the left side.
    private var lineNumberRuler: SourceCodeRulerView?

    var languageDelegate: SourceCodeViewLanguageDelegate? {
        didSet {
            languageDelegate?.prepareForSourceCodeView(self)
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


    private var languageCompletions: LanguageCompletions?

    private lazy var completionViewController: CompletionViewController = {
        let completionViewController = CompletionViewController()
        completionViewController.delegateAndDataSource = self
        return completionViewController
    }()

    private lazy var completionPopover: NSPopover = {
        let popover = NSPopover()
        popover.animates = true
        popover.contentViewController = completionViewController
        popover.appearance = NSAppearance(named: .vibrantDark)

        return popover
    }()

    func selectCompletion(at index: Int) {
        let newIndex = min(max(index, 0), languageCompletions?.count ?? 0)
        completionViewController.tableView.selectRowIndexes(IndexSet(integer: newIndex), byExtendingSelection: false) //TODO: replace with actuall count
    }

    func insertCompletion(at index: Int) {
        closeCompletionPopover()
        guard let languageCompletions = languageCompletions else {
            return
        }

        let completion = languageCompletions.words[index].completionString
        textStorage?.replaceCharacters(in: languageCompletions.rangeForUserCompletion, with: languageCompletions.words[index].completionString, byUser: true)
        goToFirstPlaceholder(inRange: NSRange(location: languageCompletions.rangeForUserCompletion.location, length: completion.count))
    }

    override func keyDown(with event: NSEvent) {
        let char = event.characters?.utf16.first

        if completionPopover.isShown, let char = char {
            switch char {
            case 13: // return
                insertCompletion(at: completionViewController.tableView.selectedRow)
            case 63232: // up
                selectCompletion(at: completionViewController.tableView.selectedRow - 1)
            case 63233: // down
                selectCompletion(at: completionViewController.tableView.selectedRow + 1)
            case ...31, 63234, 63235: // controll characters, left, right
                closeCompletionPopover()
                super.keyDown(with: event)
            default:
                super.keyDown(with: event)
                complete(self)
            }
        } else {
            let typedString = event.charactersIgnoringModifiers
            let controlModifier = event.modifierFlags.contains(NSEvent.ModifierFlags.control)

            if controlModifier && typedString == " " {
                complete(self)
            } else if typedString == "\\" {
                super.keyDown(with: event)
                complete(self)
            } else {
                super.keyDown(with: event)
            }
        }
    }

    func numberOfRows(in tableView: NSTableView) -> Int {
        return languageCompletions?.count ?? 0
    }

    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        guard let languageCompletions = languageCompletions else {
            return nil
        }

        guard let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "completionTableCell"), owner: nil) as? NSTableCellView else {
            return nil
        }

        if row < languageCompletions.count {
            cell.textField?.stringValue = languageCompletions.words[row].displayString
            cell.imageView?.image = languageCompletions.words[row].image
        }

        return cell
    }

    func tableView(_ tableView: NSTableView, rowViewForRow row: Int) -> NSTableRowView? {
        return CompletionTableRowView()
    }

    func tableViewSelectionDidChange(_ notification: Notification) {
        completionViewController.tableView.scrollRowToVisible(completionViewController.tableView.selectedRow)
    }

    func completionTableView(_ tableView: NSTableView, doubleClicked row: Int) {
        insertCompletion(at: row)
    }

    func closeCompletionPopover() {
        completionPopover.close()
    }

    override func resignFirstResponder() -> Bool {
        closeCompletionPopover()
        return super.resignFirstResponder()
    }

    override func mouseDown(with event: NSEvent) {
        closeCompletionPopover()
        super.mouseDown(with: event)
    }

    override func complete(_ sender: Any?) {
        guard let layoutManager = layoutManager, let textContainer = textContainer else {
            return
        }

        languageDelegate?.sourceCodeView(self, completionsForLocation: selectedRange().location) {
            self.languageCompletions = $0
            let count = $0?.count ?? 0
            if count > 0 {
                let size = NSSize(width: 250, height: 19 * min(count, 10))
                self.completionViewController.view.setFrameSize(size)
                self.completionPopover.contentSize = size

                let glyphRange = NSRange(location: self.selectedRange().location, length: 0)
                let characterRect = layoutManager.boundingRect(forGlyphRange: glyphRange, in: textContainer)
                let newRect = NSRect(x: characterRect.minX, y: characterRect.maxY, width: 1, height: 1)

                self.completionPopover.show(relativeTo: newRect, of: self, preferredEdge: .maxY)
                self.completionViewController.tableView.reloadData()
                self.selectCompletion(at: 0)
            } else {
                self.closeCompletionPopover()
            }
        }
    }
}

protocol SourceCodeHighlightRule: class {
    func applyRule(to sourceCodeView: SourceCodeView, range: NSRange)
}

protocol SourceCodeViewDelegate: class {
    func sourceCodeViewStructureChanged(_ sourceCodeView: SourceCodeView)
}

private class CompletionTableRowView: NSTableRowView {
    override func drawSelection(in dirtyRect: NSRect) {
        NSColor.selectedMenuItemColor.set()
        let path = NSBezierPath(rect: bounds)
        path.stroke()
        path.fill()
    }

    override var interiorBackgroundStyle: NSView.BackgroundStyle {
        if isSelected {
            return .dark
        } else {
            return .light
        }
    }
}





