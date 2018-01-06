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
    func createBinaryFile(at path: String, withData data: Data) -> FileModel {
        // swiftlint:disable force_cast
        let file = NSEntityDescription.insertNewObject(forEntityName: "File", into: self) as! FileModel
        file.relativePath = path
        file.createCommit = createCreateFileCommit()
        file.data = createFileDataModel(withContent: data)
        file.updateFileHash()
        return file
    }
}
