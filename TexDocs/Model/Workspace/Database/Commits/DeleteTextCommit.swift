//
//  DeleteTextCommit.swift
//  TexDocs
//
//  Created by Noah Peeters on 21.12.17.
//  Copyright © 2017 TexDocs. All rights reserved.
//

import Foundation

protocol DeleteTextCommit: FileContentCommit {
    var location: Int64 { get }
    var length: Int64 { get }
}

extension DeleteTextCommitModel: DeleteTextCommit {}

extension NSManagedObjectContext {
    func createDeleteTextCommit(inFile file: VersionedFileModel, atLocation location: Int, withLength length: Int) -> DeleteTextCommitModel {
        // swiftlint:disable force_cast
        let commit = NSEntityDescription.insertNewObject(forEntityName: "DeleteTextCommit", into: self) as! DeleteTextCommitModel
        commit.file = file
        commit.location = Int64(location)
        commit.length = Int64(length)
        return commit
    }
}
