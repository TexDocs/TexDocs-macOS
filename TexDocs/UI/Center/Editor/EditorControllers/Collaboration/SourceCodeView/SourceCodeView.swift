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

    weak var sourceCodeViewDelegate: SourceCodeViewDelegate?
    weak var editableFileSystemItem: EditableFileSystemItem? {
        didSet {
            updateSourceCodeHighlighting(in: stringRange)
            updateFont()
        }
    }

    override func setUp() {
        super.setUp()

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(updateTheme),
            name: UserDefaults.themeName.notificationKey,
            object: nil)
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(updateFont),
            name: UserDefaults.editorFontName.notificationKey,
            object: nil)
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(updateFont),
            name: UserDefaults.editorFontSize.notificationKey,
            object: nil)
    }

    // MARK: View life cycle

    override func viewDidMoveToSuperview() {
        super.viewDidMoveToSuperview()
        setUpLineNumberRuler()
    }

    // MARK: Events

    override func insertNewline(_ sender: Any?) {
        super.insertNewline(sender)

        // -2: -1 (\n newline) + -1 (arrays start with 0)
        if let path = editableFileSystemItem?.rootStructureNode?.path(toPosition: currentLineRange.upperBound - 2, range: \.indentRange) {
            insertText(String(repeating: " ", count: (path.count - 1) * 4))

            if let closableDocumentStructureNode = path.last as? ClosableDocumentStructureNode, !closableDocumentStructureNode.closed {
                let selection = selectedRange()
                insertText("\n" + String(repeating: " ", count: (path.count - 2) * 4) + closableDocumentStructureNode.closeString)
                setSelectedRange(selection)
            }
        }
    }

    override func paste(_ sender: Any?) {
        if let string = NSPasteboard.general.string(forType: .string) {
            textStorage?.replaceCharacters(in: selectedRange(), with: string, byUser: true, updateIndent: true)
        }
    }

    override func deleteBackward(_ sender: Any?) {
        let lineRange = currentLineRange
        guard selectedRange().length == 0 else {
            super.deleteBackward(sender)
            return
        }
        let relativeLocation = selectedRange().location - lineRange.location

        guard relativeLocation > 0, string[lineRange].leadingSpaces >= relativeLocation else {
            super.deleteBackward(sender)
            return
        }

        decreaseIndent()
    }

    @objc func updateTheme() {
        updateSourceCodeHighlighting(in: stringRange)
    }

    // MARK: Line Number

    override func updateRuler() {
        lineNumberRuler?.redrawLineNumbers()
    }

    @objc func updateFont() {
        guard let font = UserDefaults.editorFont else {
            return
        }
        textStorage?.font = font
    }

    // MARK: - Completion

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

    override func resignFirstResponder() -> Bool {
        closeCompletionPopover()
        return super.resignFirstResponder()
    }

    override func mouseDown(with event: NSEvent) {
        closeCompletionPopover()
//        textStorage?.deselectAllTokens()
        super.mouseDown(with: event)
    }

//    func textView(_ textView: NSTextView, willChangeSelectionFromCharacterRange oldSelectedCharRange: NSRange, toCharacterRange newSelectedCharRange: NSRange) -> NSRange {
//
//        textStorage?.deselectAllTokens()
//
//        let deltaMovement = newSelectedCharRange.location - oldSelectedCharRange.location
//        guard oldSelectedCharRange.length == 0, abs(deltaMovement) == 1 else {
//            return newSelectedCharRange
//        }
//
//        let movedForward = deltaMovement > 0
//        let checkPositon = movedForward ? oldSelectedCharRange.location : newSelectedCharRange.location
//
//        guard checkPositon < nsString.length, let attachment = textStorage?.attribute(.attachment, at: checkPositon, effectiveRange: nil) as? NSTextAttachment else {
//            return newSelectedCharRange
//        }
//
//        if let token = attachment.attachmentCell as? TokenCell {
//            token.isSelected = true
//        }
//
//        return NSRange(location: checkPositon, length: 1)
//    }

    override func complete(_ sender: Any?) {
        guard let layoutManager = layoutManager, let textContainer = textContainer else {
            return
        }

        editableFileSystemItem?.languageDelegate?.sourceCodeView(self, completionsForLocation: selectedRange().location) {
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

    func textView(_ textView: NSTextView, clickedOn cell: NSTextAttachmentCellProtocol, in cellFrame: NSRect, at charIndex: Int) {
        setSelectedRange(NSRange(location: charIndex, length: 1))
    }
}

extension SourceCodeView {
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

    private func editableFileSystemItemReloaded(_ editableFileSystemItem: EditableFileSystemItem) {
        updateFont()
    }

    func rulerViewAnnotationClicked(annotation: RulerAnnotation, inRuler ruler: NSRulerView, rect: NSRect) {
        sourceCodeViewDelegate?.sourceCodeView(self, annotationClicked: annotation, inRuler: ruler, rect: rect)
    }

    func updateSourceCodeHighlighting(in editedRange: NSRange) {
        editableFileSystemItem?.languageDelegate?.sourceCodeView(self, updateCodeHighlightingInRange: editedRange)
    }
}

extension SourceCodeView: VersionedFileDelegate {
    func versionedFile(_ versionedFile: VersionedFileModel, textDidChangeInOldRange oldRange: NSRange, newRange: NSRange, changeInLength delta: Int, byUser: Bool, newString: String) {
        updateSourceCodeHighlighting(in: newRange)
        sourceCodeViewDelegate?.sourceCodeViewStructureChanged(self)
    }
}

extension SourceCodeView: CompletionViewControllerDelegate {
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
        textStorage?.replaceCharacters(in: languageCompletions.rangeForUserCompletion, with: completion, byUser: true)
        //        goToFirstPlaceholder(inRange: NSRange(location: languageCompletions.rangeForUserCompletion.location, length: NSString(string: completion).length))
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
                //            } else if typedString == "\t" {
                //                if !goToNextPlaceholder() {
                //                    let currentLineRange = self.currentLineRange
                //                    let currentLine = string[currentLineRange]
                //                    let positionInLine = selectedRange().location - currentLineRange.location
                //
                //                    if selectedRange().length > 0 || currentLine.leadingSpaces >= positionInLine {
                //                        incraseIndent()
                //                    } else {
                //                        super.keyDown(with: event)
                //                    }
                //                }
                //            } else if typedString == "\u{19}" { // shift-tab
                //                if !goToPreviousPlaceholder() {
                //                    decreaseIndent()
                //                }
            } else {
                super.keyDown(with: event)
            }
        }
    }

    func closeCompletionPopover() {
        completionPopover.close()
    }
}

protocol SourceCodeHighlightRule: class {
    func applyRule(to sourceCodeView: SourceCodeView, range: NSRange)
}

protocol SourceCodeViewDelegate: class {
    func sourceCodeViewStructureChanged(_ sourceCodeView: SourceCodeView)
    func sourceCodeView(_ sourceCodeView: SourceCodeView, annotationClicked annotation: RulerAnnotation, inRuler ruler: NSRulerView, rect: NSRect)
}
