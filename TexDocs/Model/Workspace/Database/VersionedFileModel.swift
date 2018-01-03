//
//  VersionedFileModel.swift
//  TexDocs
//
//  Created by Noah Peeters on 21.12.17.
//  Copyright © 2017 TexDocs. All rights reserved.
//

import Foundation

@objc(VersionedFileModel)
public class VersionedFileModel: FileModel, NSTextStorageDelegate {
    private(set) lazy var commitsFetchedResultController: SimpleFetchedResultsController<FileContentCommitModel> = {
        let request: NSFetchRequest<FileContentCommitModel> = FileContentCommitModel.fetchRequest()
        request.sortDescriptors = [
            NSSortDescriptor(key: "index", ascending: true)
        ]
        request.predicate = NSPredicate(format: "file == %@", self)
        let controller = SimpleFetchedResultsController(request: request, managedObjectContext: managedObjectContext!)
        return controller
    }()

    private(set) lazy var textStorage: NSTextStorage = {
        guard let data = data?.data, let string = String(data: data, encoding: .utf8) else {
            return NSTextStorage()
        }

        let textStorage = NSTextStorage(string: string)

        textStorage.delegate = self
        return textStorage
    }()

    func commits(withIndexGreaterThanOrEqualTo lowerBound: Int) -> [FileContentCommitModel] {
        guard let managedObjectContext = managedObjectContext else {
            return []
        }

        let request: NSFetchRequest<FileContentCommitModel> = FileContentCommitModel.fetchRequest()
        request.sortDescriptors = [
            NSSortDescriptor(key: "index", ascending: true)
        ]
        request.predicate = NSPredicate(format: "file == %@ AND index >= i", self, lowerBound)

        return (try? managedObjectContext.fetch(request)) ?? []
    }

    func applyFileContentCommit(_ commit: FileContentCommit) {
        if let insertTextCommit = commit as? InsertTextCommit, let text = insertTextCommit.text {
            let range = NSRange(location: Int(insertTextCommit.location), length: 0)
            textStorage.replaceCharacters(in: range, with: text, byUser: false, updateIndent: true)
        } else if let deleteTextCommit = commit as? DeleteTextCommit {
            let range = NSRange(location: Int(deleteTextCommit.location), length: Int(deleteTextCommit.length))
            textStorage.replaceCharacters(in: range, with: "", byUser: false, updateIndent: true)
        }
    }

    var pathExtension: String {
        return relativePath?.components(separatedBy: ".").last ?? ""
    }

    fileprivate var userInitiated = true
    var collaborationDelegate: VersionedFileCollaborationDelegate?
    let delegates = MultiDelegate<VersionedFileDelegate>()
    private(set) lazy var languageDelegate: LanguageDelegate? = {
        allLanguageDelegates[pathExtension]?.init()
    }()

    public func textStorage(_ textStorage: NSTextStorage, didProcessEditing editedMask: NSTextStorageEditActions, range editedRange: NSRange, changeInLength delta: Int) {
        if editedMask.contains(NSTextStorageEditActions.editedCharacters) {
            let oldRange = NSRange(location: editedRange.location, length: editedRange.length - delta)

            languageDelegate?.textStorageUpdated(textStorage)

            let newString = textStorage.string[editedRange]
            collaborationDelegate?.versionedFile(self, textDidChangeInOldRange: oldRange, newRange: editedRange, changeInLength: delta, byUser: userInitiated, newString: newString)
            delegates.forEach {
                $0.versionedFile(self, textDidChangeInOldRange: oldRange, newRange: editedRange, changeInLength: delta, byUser: userInitiated, newString: newString)
            }

            // TODO: Improve performance
            data?.data = textStorage.string.data(using: .utf8)
        }
    }
}

@objc protocol VersionedFileDelegate: class {
    func versionedFile(_ versionedFile: VersionedFileModel, textDidChangeInOldRange oldRange: NSRange, newRange: NSRange, changeInLength delta: Int, byUser: Bool, newString: String)
}

protocol VersionedFileCollaborationDelegate: VersionedFileDelegate {}

extension NSManagedObjectContext {
    func createVersionedFile(at path: String) -> VersionedFileModel {
        let file = NSEntityDescription.insertNewObject(forEntityName: "VersionedFile", into: self) as! VersionedFileModel
        file.relativePath = path
        file.createCommit = createCreateFileCommit()
        file.data = createFileDataModel()
        file.updateFileHash()
        return file
    }
}

extension NSTextStorage {
    func replaceCharacters(in range: NSRange, with str: String, byUser: Bool, updateIndent: Bool = true) {
        let verisonedFileModel = delegate as? VersionedFileModel
        verisonedFileModel?.userInitiated = byUser
        replaceCharacters(in: range, with: str)
        verisonedFileModel?.userInitiated = true

        //        let lineRange = NSString(string: string)
        //            .lineRange(for: NSRange(
        //                location: range.location,
        //                length: NSString(string: str).length))
        //        editableFileSystemItem?.userInitiated = false
        //        let insertedTextShift = createTokens(in: lineRange)
        //        editableFileSystemItem?.userInitiated = true
        //
        //        if let textViewDelegate = editableFileSystemItem, updateIndent, byUser {
        //            textViewDelegate.updateIndent(in: NSRange(
        //                location: range.location,
        //                length: NSString(string: str).length + insertedTextShift))
        //        }
    }
}
