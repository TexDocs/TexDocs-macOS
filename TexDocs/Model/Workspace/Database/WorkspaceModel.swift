//
//  WorkspaceModel.swift
//  TexDocs
//
//  Created by Noah Peeters on 19.12.17.
//  Copyright © 2017 TexDocs. All rights reserved.
//

import Foundation
import CoreData

extension WorkspaceModel {
    static func mainFetchRequest() -> NSFetchRequest<WorkspaceModel> {
        let request: NSFetchRequest<WorkspaceModel> = fetchRequest()
        request.fetchLimit = 1
        return request
    }
}

extension NSManagedObjectContext {
    func createWorkspaceModel() -> WorkspaceModel {
        return WorkspaceModel(
            entity: NSEntityDescription.entity(forEntityName: "WorkspaceModel", in: self)!,
            insertInto: self)
    }
}
