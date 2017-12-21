//
//  DeleteFileCommit.swift
//  TexDocs
//
//  Created by Noah Peeters on 21.12.17.
//  Copyright © 2017 TexDocs. All rights reserved.
//

import Foundation

extension NSManagedObjectContext {
    func createDeleteFileCommit(forFile file: FileModel) -> DeleteFileCommit {
        let commit = NSEntityDescription.insertNewObject(forEntityName: "DeleteFileCommit", into: self) as! DeleteFileCommit
        commit.deletedFile = file
        return commit
    }
}
