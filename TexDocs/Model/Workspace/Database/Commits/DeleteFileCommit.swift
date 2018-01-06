//
//  DeleteFileCommit.swift
//  TexDocs
//
//  Created by Noah Peeters on 21.12.17.
//  Copyright © 2017 TexDocs. All rights reserved.
//

import Foundation

extension NSManagedObjectContext {
    func createDeleteFileCommit(forFile file: FileModel) -> DeleteFileCommitModel {
        // swiftlint:disable force_cast
        let commit = NSEntityDescription.insertNewObject(forEntityName: "DeleteFileCommit", into: self) as! DeleteFileCommitModel
        commit.deletedFile = file
        return commit
    }
}
