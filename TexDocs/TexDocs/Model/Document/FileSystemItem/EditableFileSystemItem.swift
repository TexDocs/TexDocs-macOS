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
    let languageDelegate: SourceCodeViewLanguageDelegate?

    private var tokens: [TokenCell] = []

    override var editorControllerTypes: [EditorController.Type] {
        return [[CollaborationEditorViewController.self], super.editorControllerTypes].flatMap { $0}
    }

    override init(_ url: URL) throws {
        languageDelegate = allLanguageDelegates[url.pathExtension]?.init()
        try super.init(url)
        textStorage.delegate = self

        try reload()

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

    @objc func updateFont() {
        guard let font = UserDefaults.editorFont else {
            return
        }
        textStorage.font = font
    }

    override func save() throws {
        try super.save()

        removeAllTokens()
        try textStorage.string.write(to: url, atomically: false, encoding: .utf8)
        createAllTokens()
    }

    func deselectAllTokens() {
        for token in tokens {
            token.selected = false
        }
    }

    private func removeAllTokens() {
        tokens.removeAll(keepingCapacity: true)
        textStorage.enumerateAttribute(
            .attachment,
            in: NSRange(location: 0, length: textStorage.length),
            options: []) { attachment, range, _ in
                guard let attachment = attachment as? NSTextAttachment,
                    let cell = attachment.attachmentCell as? TokenCell else {
                        return
                }
                textStorage.replaceCharacters(in: range, with: "{#\(cell.text.string)#}", byUser: false)
        }
    }

    private func createAllTokens() {
        createTokens(in: NSRange(textStorage.string.startIndex..<textStorage.string.endIndex, in: textStorage.string))
    }

    private func createTokens(in range: NSRange) {
        let matches = EditorPlaceHolderRegex.matches(in: textStorage.string, options: [], range: range)

        for match in matches {
            let regexMatch = match.regularExpressionMatch(in: textStorage.string)
            let tokenCell = TokenCell(text: regexMatch.captureGroups[1].string)
            let attachment = NSTextAttachment(data: nil, ofType: nil)
            attachment.attachmentCell  = tokenCell
            textStorage.replaceCharacters(in: match.range, with: NSAttributedString(attachment: attachment))
            tokens.append(tokenCell)
        }
    }

    override func reload() throws {
        try super.reload()
        let newString = try String(contentsOf: url)
        textStorage.replaceContent(with: newString)
        updateFont()
        createAllTokens()
    }

    // MARK: Text did change

    fileprivate var userInitiated = true
    fileprivate var isContentReplace = false

    func textStorage(_ textStorage: NSTextStorage, didProcessEditing editedMask: NSTextStorageEditActions, range editedRange: NSRange, changeInLength delta: Int) {
        if editedMask.contains(NSTextStorageEditActions.editedCharacters) {
            let oldRange = NSRange(location: editedRange.location, length: editedRange.length - delta)
            delegates.forEach {
                $0.textDidChange(oldRange: oldRange, newRange: editedRange, changeInLength: delta, byUser: userInitiated, isContentReplace: isContentReplace)
            }

            let lineRange = NSString(string: textStorage.string).lineRange(for: editedRange)
            createTokens(in: lineRange)
        }
    }
}

@objc protocol EditableFileSystemItemDelegate: class {
    func textDidChange(oldRange: NSRange, newRange: NSRange, changeInLength delta: Int, byUser: Bool, isContentReplace: Bool)
}

extension NSTextStorage {
    func replaceCharacters(in range: NSRange, with str: String, byUser: Bool) {
        let textViewDelegate = delegate as? EditableFileSystemItem
        textViewDelegate?.userInitiated = byUser
        replaceCharacters(in: range, with: str)
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
