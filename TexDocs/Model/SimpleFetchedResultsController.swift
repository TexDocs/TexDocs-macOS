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
    let mapper: ((ResultType) -> Void)?

    init(request: NSFetchRequest<ResultType>, managedObjectContext: NSManagedObjectContext, mapper: ((ResultType) -> Void)? = nil) {
        self.request = request
        self.managedObjectContext = managedObjectContext
        self.mapper = mapper
    }

    func numberOfItems() -> Int {
        return (try? managedObjectContext.count(for: request)) ?? 0
    }

    func fetch(offset: Int = 0, limit: Int = 0) -> [ResultType] {
        request.fetchLimit = limit
        request.fetchOffset = offset
        let result = (try? managedObjectContext.fetch(request)) ?? []
        if let mapper = mapper {
            result.forEach(mapper)
        }
        return result
    }

    subscript(index: Int) -> ResultType? {
        return fetch(offset: index, limit: 1).first
    }

    subscript(from: CountablePartialRangeFrom<Int>) -> [ResultType] {
        return fetch(offset: from.lowerBound)
    }

    subscript(upTo upper: PartialRangeUpTo<Int>) -> [ResultType] {
        return fetch(limit: upper.upperBound)
    }
}
