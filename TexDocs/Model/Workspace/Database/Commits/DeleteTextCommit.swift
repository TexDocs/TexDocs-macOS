//
//  DeleteTextCommit.swift
//  TexDocs
//
//  Created by Noah Peeters on 21.12.17.
//  Copyright © 2017 TexDocs. All rights reserved.
//

import Foundation

extension NSManagedObjectContext {
    func createDeleteTextCommit(inFile file: VersionedFileModel, atLocation location: Int, withLength length: Int) -> DeleteTextCommit {
        let commit = NSEntityDescription.insertNewObject(forEntityName: "DeleteTextCommit", into: self) as! DeleteTextCommit
        commit.file = file
        commit.location = Int64(location)
        commit.length = Int64(length)
        return commit
    }
}
