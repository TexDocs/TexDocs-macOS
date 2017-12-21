//
//  FileDataModel.swift
//  TexDocs
//
//  Created by Noah Peeters on 20.12.17.
//  Copyright © 2017 TexDocs. All rights reserved.
//

import Foundation

extension NSManagedObjectContext {
    func createFileDataModel(withContent data: Data = Data()) -> FileDataModel {
        let fileData = NSEntityDescription.insertNewObject(forEntityName: "FileData", into: self) as! FileDataModel
        fileData.data = data
        return fileData
    }
}

