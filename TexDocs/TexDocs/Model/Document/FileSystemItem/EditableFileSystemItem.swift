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

        let outputTextStorage = NSTextStorage(attributedString: textStorage)
        outputTextStorage.removeAllTokens()
        try outputTextStorage.string.write(to: url, atomically: false, encoding: .utf8)
    }

    override func reload() throws {
        try super.reload()
        let newString = try String(contentsOf: url)
        textStorage.replaceContent(with: newString)
        updateFont()
        textStorage.createAllTokens()
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
            textStorage.createTokens(in: lineRange)
            updateFont()
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
