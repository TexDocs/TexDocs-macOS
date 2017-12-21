//
//  VersionedFileModel.swift
//  TexDocs
//
//  Created by Noah Peeters on 21.12.17.
//  Copyright © 2017 TexDocs. All rights reserved.
//

import Foundation

@objc(VersionedFileModel)
public class VersionedFileModel: FileModel {
    lazy var commitsFetchedResultController: SimpleFetchedResultsController<FileContentCommit> = {
        let request: NSFetchRequest<FileContentCommit> = FileContentCommit.fetchRequest()
        request.sortDescriptors = [
            NSSortDescriptor(key: "index", ascending: true)
        ]
        request.predicate = NSPredicate(format: "file == %@", self)
        let controller = SimpleFetchedResultsController(request: request, managedObjectContext: managedObjectContext!)
        return controller
    }()

    func commits(withIndexGreaterOrEqualTo lowerBound: Int) -> [FileContentCommit] {
        guard let managedObjectContext = managedObjectContext else {
            return []
        }

        let request: NSFetchRequest<FileContentCommit> = FileContentCommit.fetchRequest()
        request.sortDescriptors = [
            NSSortDescriptor(key: "index", ascending: true)
        ]
        request.predicate = NSPredicate(format: "file == %@ AND index >= i", self, lowerBound)

        return (try? managedObjectContext.fetch(request)) ?? []
    }

    func appendFileContentCommit(_ commit: FileContentCommit) {
        commit.file = self

        if let insertTextCommit = commit as? InsertTextCommit, let newData = insertTextCommit.text?.data(using: .utf8), let originalData = self.data?.data {
            self.data?.data = originalData[..<insertTextCommit.location] + newData + originalData[insertTextCommit.location...]
        } else if let deleteTextCommit = commit as? DeleteTextCommit {
            self.data?.data?.removeSubrange(Int(deleteTextCommit.location)..<Int(deleteTextCommit.location + deleteTextCommit.length))
        }
    }
}
