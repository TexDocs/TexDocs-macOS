//
//  InsertTextCommit.swift
//  TexDocs
//
//  Created by Noah Peeters on 21.12.17.
//  Copyright © 2017 TexDocs. All rights reserved.
//

import Foundation

protocol InsertTextCommit: FileContentCommit {
    var location: Int64 { get }
    var text: String? { get }
}

extension InsertTextCommitModel: InsertTextCommit {}

extension NSManagedObjectContext {
    func createInsertTextCommit(inFile file: VersionedFileModel, atLocation location: Int, text: String) -> InsertTextCommitModel {
        // swiftlint:disable force_cast
        let commit = NSEntityDescription.insertNewObject(forEntityName: "InsertTextCommit", into: self) as! InsertTextCommitModel
        commit.file = file
        commit.location = Int64(location)
        commit.text = text
        return commit
    }
}
