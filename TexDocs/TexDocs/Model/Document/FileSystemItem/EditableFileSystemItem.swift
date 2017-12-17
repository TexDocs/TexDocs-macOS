//
//  EditableFileSystemItem.swift
//  TexDocs
//
//  Created by Noah Peeters on 05.12.17.
//  Copyright © 2017 TexDocs. All rights reserved.
//

import Cocoa

class EditableFileSystemItem: FileSystemItem, NSTextStorageDelegate {
    let textStorage = NSTextStorage()

    let delegates = MultiDelegate<EditableFileSystemItemDelegate>()
    let languageDelegate: LanguageDelegate?
    private(set) var rootStructureNode: CachedProperty<DocumentStructureNode?>!
    private(set) var annotations: CachedProperty<[RulerAnnotation]>!

    override var editorControllerTypes: [EditorController.Type] {
        return [[CollaborationEditorViewController.self], super.editorControllerTypes].flatMap { $0}
    }

    override init(_ url: URL) throws {
        languageDelegate = allLanguageDelegates[url.pathExtension]?.init()
        languageDelegate?.prepareForTextStorage(textStorage)

        try super.init(url)

        rootStructureNode = CachedProperty(block: { [weak self] in
            guard let unwrappedSelf = self else { return nil }
            return unwrappedSelf.languageDelegate?.textStorageDocumentStructure(unwrappedSelf.textStorage)
        })

        annotations = CachedProperty(block: { [weak self] in
            guard let unwrappedSelf = self else { return [] }
            return unwrappedSelf.languageDelegate?.textStorageRulerAnnotations(unwrappedSelf.textStorage) ?? []
        })

        textStorage.delegate = self
        try reload()
    }

    override func save() throws {
        try super.save()

        let outputTextStorage = NSTextStorage(attributedString: textStorage)
        outputTextStorage.removeAllTokens()
        try outputTextStorage.string.write(to: url, atomically: false, encoding: .utf8)
    }

    override func reload() throws {
        try super.reload()
        let newString = try String(contentsOf: url)
        textStorage.replaceContent(with: newString)
        textStorage.createAllTokens()
        delegates.forEach {
            $0.editableFileSystemItemReloaded(self)
        }
    }

    // MARK: Text did change

    fileprivate var userInitiated = true
    fileprivate var isContentReplace = false
    fileprivate var insertedTextShift = 0

    func textStorage(_ textStorage: NSTextStorage, didProcessEditing editedMask: NSTextStorageEditActions, range editedRange: NSRange, changeInLength delta: Int) {
        if editedMask.contains(NSTextStorageEditActions.editedCharacters) {
            let oldRange = NSRange(location: editedRange.location, length: editedRange.length - delta)
            rootStructureNode.invalidateCache()
            annotations.invalidateCache()
            delegates.forEach {
                $0.textDidChange(oldRange: oldRange, newRange: editedRange, changeInLength: delta, byUser: userInitiated, isContentReplace: isContentReplace)
                $0.editableFileSystemItemDocumentStructureChanged(self)
            }
            let lineRange = NSString(string: textStorage.string).lineRange(for: editedRange)
            insertedTextShift = textStorage.createTokens(in: lineRange)
        }
    }

    fileprivate func updateIndent(in range: NSRange) {
        guard let structureNode = rootStructureNode.value else {
            return
        }

        let newLineRegex = try! NSRegularExpression(pattern: ".*?\n", options: [])
        var totalShift = 0
        let string = textStorage.string
        for match in newLineRegex.matches(in: string, options: [], range: NSString(string: string).lineRange(for: range)) {
            let lineRange = match.range
            let lineString = string[lineRange]
            let currentIndent = lineString.leadingSpaces
            let targetIndent = (structureNode.path(toPosition: lineRange.upperBound - 2, range: \.indentRange).count - 1) * 4
            if currentIndent != targetIndent {
                textStorage.replaceCharacters(
                    in: NSRange(location: lineRange.location, length: currentIndent).shifted(by: totalShift),
                    with: String(repeating: " ", count: targetIndent),
                    byUser: true,
                    updateIndent: false)
                totalShift += targetIndent - currentIndent
            }
        }
    }
}

@objc protocol EditableFileSystemItemDelegate: class {
    func textDidChange(oldRange: NSRange, newRange: NSRange, changeInLength delta: Int, byUser: Bool, isContentReplace: Bool)
    func editableFileSystemItemDocumentStructureChanged(_ editableFileSystemItem: EditableFileSystemItem)
    func editableFileSystemItemReloaded(_ editableFileSystemItem: EditableFileSystemItem)
}

extension NSTextStorage {
    func replaceCharacters(in range: NSRange, with str: String, byUser: Bool, updateIndent: Bool = true) {
        let textViewDelegate = delegate as? EditableFileSystemItem
        textViewDelegate?.userInitiated = byUser
        replaceCharacters(in: range, with: str)

        if let textViewDelegate = textViewDelegate {
            textViewDelegate.updateIndent(in: NSRange(
                location: range.location,
                length: NSString(string: str).length + textViewDelegate.insertedTextShift))
        }
        textViewDelegate?.userInitiated = true
    }

    func replaceContent(with str: String) {
        let textViewDelegate = delegate as? EditableFileSystemItem
        textViewDelegate?.userInitiated = false
        textViewDelegate?.isContentReplace = true
        replaceCharacters(in: NSRange(location: 0, length: length), with: str)
        textViewDelegate?.isContentReplace = false
        textViewDelegate?.userInitiated = true
    }
}
