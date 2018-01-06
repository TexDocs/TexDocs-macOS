//
//  SchemeModel.swift
//  TexDocs
//
//  Created by Noah Peeters on 19.12.17.
//  Copyright © 2017 TexDocs. All rights reserved.
//

import Foundation

extension SchemeModel {
    var uuid: UUID? {
        get {
            guard let uuidData = uuidData else {
                return nil
            }
            return UUID(data: uuidData)
        }
        set {
            uuidData = newValue?.data
        }
    }
}

extension NSManagedObjectContext {
    func createSchemeModel(name: String, path: String) -> SchemeModel {
        // swiftlint:disable force_cast
        let scheme = NSEntityDescription.insertNewObject(forEntityName: "Scheme", into: self) as! SchemeModel
        scheme.name = name
        scheme.path = path
        scheme.uuid = UUID()
        return scheme
    }
}
