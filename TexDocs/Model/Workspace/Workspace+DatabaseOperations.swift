//
//  Workspace+DatabaseOperations.swift
//  TexDocs
//
//  Created by Noah Peeters on 20.12.17.
//  Copyright © 2017 TexDocs. All rights reserved.
//

import Foundation

extension Workspace {
    func asyncDatabaseOperations(operations: @escaping (NSManagedObjectContext) throws -> Void, completion: ((Bool) -> Void)? = nil) {
        guard let managedObjectContext = managedObjectContext else {
            completion?(false)
            return
        }

        databaseQueue.async {
            try? operations(managedObjectContext)

            DispatchQueue.main.async {
                completion?(true)
            }
        }
    }

    func asyncDatabaseOperations<Result>(operations: @escaping (NSManagedObjectContext) throws -> Result,
                                         completion: ((Result?) -> Void)? = nil) {
        guard let managedObjectContext = managedObjectContext else {
            completion?(nil)
            return
        }

        databaseQueue.async {
            let result = try? operations(managedObjectContext)

            DispatchQueue.main.async {
                completion?(result)
            }
        }
    }

    @discardableResult func syncDatabaseOperations(operations: (NSManagedObjectContext) throws -> Void) -> Bool {
        guard let managedObjectContext = managedObjectContext else {
            return false
        }

        databaseQueue.sync {
            try? operations(managedObjectContext)
        }
        return true
    }

    @discardableResult func syncDatabaseOperations<Result>(
                                operations: (NSManagedObjectContext) throws -> Result) -> Result? {
        guard let managedObjectContext = managedObjectContext else {
            return nil
        }

        var result: Result?
        databaseQueue.sync {
            result = try? operations(managedObjectContext)
        }
        return result
    }
}
