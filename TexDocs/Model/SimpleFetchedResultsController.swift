//
//  SimpleFetchedResultsController.swift
//  TexDocs
//
//  Created by Noah Peeters on 22.12.17.
//  Copyright © 2017 TexDocs. All rights reserved.
//

import CoreData

class SimpleFetchedResultsController<ResultType: NSManagedObject> {
    let request: NSFetchRequest<ResultType>
    let managedObjectContext: NSManagedObjectContext

    init(request: NSFetchRequest<ResultType>, managedObjectContext: NSManagedObjectContext) {
        self.request = request
        self.managedObjectContext = managedObjectContext
    }

    func numberOfItems() -> Int {
        return (try? managedObjectContext.count(for: request)) ?? 0
    }

    func fetch(offset: Int = 0, limit: Int = 0) -> [ResultType] {
        request.fetchLimit = limit
        request.fetchOffset = offset
        return (try? managedObjectContext.fetch(request)) ?? []
    }

    subscript(index: Int) -> ResultType? {
        return fetch(offset: index, limit: 1).first
    }

    subscript(from: CountablePartialRangeFrom<Int>) -> [ResultType] {
        return fetch(offset: from.lowerBound)
    }

    subscript(to: PartialRangeUpTo<Int>) -> [ResultType] {
        return fetch(limit: to.upperBound)
    }
}
