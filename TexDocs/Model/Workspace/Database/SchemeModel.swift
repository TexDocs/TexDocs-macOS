//
//  SchemeModel.swift
//  TexDocs
//
//  Created by Noah Peeters on 19.12.17.
//  Copyright © 2017 TexDocs. All rights reserved.
//

import Foundation

extension NSManagedObjectContext {
    func createSchemeModel(name: String, path: String) -> SchemeModel {
        let scheme = NSEntityDescription.insertNewObject(forEntityName: "Scheme", into: self) as! SchemeModel
        scheme.name = name
        scheme.path = path
        scheme.uuid = UUID()
        return scheme
    }
}
