//
//  FileModel.swift
//  TexDocs
//
//  Created by Noah Peeters on 20.12.17.
//  Copyright © 2017 TexDocs. All rights reserved.
//

import Foundation
import CoreData

@objc(FileModel)
public class FileModel: NSManagedObject {
    func updateFileHash() {
        fileHash = data?.data?.generateHash()
    }
}

extension NSManagedObjectContext {
    func createVersionedFile(atPath path: String) -> VersionedFileModel {
        let file = NSEntityDescription.insertNewObject(forEntityName: "VersionedFile", into: self) as! VersionedFileModel
        file.relativePath = path
        file.createCommit = createCreateFileCommit()
        file.data = createFileDataModel()
        file.updateFileHash()
        return file
    }

    func createBinaryFile(atPath path: String, withContent data: Data) -> FileModel {
        let file = NSEntityDescription.insertNewObject(forEntityName: "File", into: self) as! FileModel
        file.relativePath = path
        file.createCommit = createCreateFileCommit()
        file.data = createFileDataModel(withContent: data)
        file.updateFileHash()
        return file
    }
}
