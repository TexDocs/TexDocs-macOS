//
//  EditableFileSystemItem.swift
//  TexDocs
//
//  Created by Noah Peeters on 05.12.17.
//  Copyright © 2017 TexDocs. All rights reserved.
//

import Cocoa

class EditableFileSystemItem: FileSystemItem, NSTextStorageDelegate {
    var versionedFileModel: VersionedFileModel {
        // swiftlint:disable force_cast
        return fileModel as! VersionedFileModel
    }

    var textStorage: NSTextStorage {
        return versionedFileModel.textStorage
    }

    var languageDelegate: LanguageDelegate? {
        return versionedFileModel.languageDelegate
    }

    var rootStructureNode: DocumentStructureNode? {
        return languageDelegate?.textStorageDocumentStructure(textStorage)
    }

    var annotations: [RulerAnnotation]? {
        return languageDelegate?.textStorageRulerAnnotations(textStorage)
    }

    override var editorControllerTypes: [EditorController.Type] {
        return [[CollaborationEditorViewController.self], super.editorControllerTypes].flatMap { $0}
    }

    init(_ url: URL, parent: FileSystemItem?, fileModel: VersionedFileModel) {
        super.init(url, parent: parent, fileModel: fileModel)
    }

    // MARK: Text did change

    fileprivate var userInitiated = true

//    func textStorage(_ textStorage: NSTextStorage, didProcessEditing editedMask: NSTextStorageEditActions, range editedRange: NSRange, changeInLength delta: Int) {
//        if editedMask.contains(NSTextStorageEditActions.editedCharacters) {
//            let oldRange = NSRange(location: editedRange.location, length: editedRange.length - delta)
//            languageDelegate?.textStorageUpdated(textStorage)
//            delegates.forEach {
//                $0.textDidChange(oldRange: oldRange, newRange: editedRange, changeInLength: delta, byUser: userInitiated)
//            }
//        }
//    }

//    fileprivate func updateIndent(in range: NSRange) {
//        guard let structureNode = rootStructureNode else {
//            return
//        }
//
//        let newLineRegex = try! NSRegularExpression(pattern: ".*?\n", options: [])
//        var totalShift = 0
//        let string = textStorage.string
//        for match in newLineRegex.matches(in: string, options: [], range: NSString(string: string).lineRange(for: range)) {
//            let lineRange = match.range
//            let lineString = string[lineRange]
//            let currentIndent = lineString.leadingSpaces
//            let targetIndent = (structureNode.path(toPosition: lineRange.upperBound - 2, range: \.indentRange).count - 1) * 4
//            if currentIndent != targetIndent {
//                textStorage.replaceCharacters(
//                    in: NSRange(location: lineRange.location, length: currentIndent).shifted(by: totalShift),
//                    with: String(repeating: " ", count: targetIndent),
//                    byUser: true,
//                    updateIndent: false)
//                totalShift += targetIndent - currentIndent
//            }
//        }
//    }
}
