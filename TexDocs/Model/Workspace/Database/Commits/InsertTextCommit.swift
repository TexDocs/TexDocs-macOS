//
//  InsertTextCommit.swift
//  TexDocs
//
//  Created by Noah Peeters on 21.12.17.
//  Copyright © 2017 TexDocs. All rights reserved.
//

import Foundation

extension NSManagedObjectContext {
    func createInsertTextCommit(inFile file: VersionedFileModel, atLocation location: Int, text: String) -> InsertTextCommit {
        let commit = NSEntityDescription.insertNewObject(forEntityName: "InsertTextCommit", into: self) as! InsertTextCommit
        commit.file = file
        commit.location = Int64(location)
        commit.text = text
        return commit
    }
}
