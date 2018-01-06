//
//  WorkspaceModel.swift
//  TexDocs
//
//  Created by Noah Peeters on 19.12.17.
//  Copyright © 2017 TexDocs. All rights reserved.
//

import Foundation
import CoreData

@objc(WorkspaceModel)
public class WorkspaceModel: NSManagedObject {
    lazy var commitsFetchedResultController: SimpleFetchedResultsController<BaseCommitModel> = {
        let request: NSFetchRequest<BaseCommitModel> = BaseCommitModel.fetchRequest()
        request.sortDescriptors = [
            NSSortDescriptor(key: "index", ascending: true)
        ]
        request.predicate = NSPredicate(format: "workspace == %@", self)
        let controller = SimpleFetchedResultsController(request: request, managedObjectContext: managedObjectContext!)
        return controller
    }()

    weak var collaborationDelegate: VersionedFileCollaborationDelegate?

    lazy var currentFilesFetchedResultController: SimpleFetchedResultsController<FileModel> = {
        let request: NSFetchRequest<FileModel> = FileModel.fetchRequest()
        request.predicate = NSPredicate(format: "workspace == %@ AND deleteCommit == NULL", self)
        let controller = SimpleFetchedResultsController(
            request: request,
            managedObjectContext: managedObjectContext!) { [weak self] in
                if let versionedFile = $0 as? VersionedFileModel {
                    versionedFile.collaborationDelegate = self?.collaborationDelegate
                }
        }
        return controller
    }()

    static func mainFetchRequest() -> NSFetchRequest<WorkspaceModel> {
        let request: NSFetchRequest<WorkspaceModel> = fetchRequest()
        request.fetchLimit = 1
        return request
    }

    func scheme(withUUID uuid: UUID) -> SchemeModel? {
        let request: NSFetchRequest<SchemeModel> = SchemeModel.fetchRequest()
        request.predicate = NSPredicate(format: "uuid == %@", uuid as CVarArg)
        request.fetchLimit = 1
        return (try? managedObjectContext?.fetch(request).first) ?? nil
    }

    func fetchAllSchemes() -> [SchemeModel] {
        return schemes?.flatMap { $0 as? SchemeModel } ?? []
    }

    func insertCommit(_ newCommit: BaseCommitModel, at index: Int) {
        for commit in commitsFetchedResultController[index...] {
            commit.index += 1
        }

        newCommit.workspace = self
        newCommit.index = Int64(index)
    }

    func appendCommit(_ commit: BaseCommitModel) {
        let index = commitsFetchedResultController.numberOfItems()
        commit.workspace = self
        commit.index = Int64(index)
        addToCommits(commit)
    }
}

extension WorkspaceModel {
    var serverURL: URL? {
        get {
            guard let serverURLString = serverURLString else {
                return nil
            }
            return URL(string: serverURLString)
        }
        set {
            serverURLString = newValue?.absoluteString
        }
    }

    var serverProjectUUID: UUID? {
        get {
            guard let serverProjectUUIDData = serverProjectUUIDData else {
                return nil
            }
            return UUID(data: serverProjectUUIDData)
        }
        set {
            serverProjectUUIDData = newValue?.data
        }
    }

    var selectedSchemeUUID: UUID? {
        get {
            guard let selectedSchemeUUIDData = selectedSchemeUUIDData else {
                return nil
            }
            return UUID(data: selectedSchemeUUIDData)
        }
        set {
            selectedSchemeUUIDData = newValue?.data
        }
    }
}

extension NSManagedObjectContext {
    func fetchOrCreateWorkspaceModel() -> WorkspaceModel {
        let response = try? fetch(WorkspaceModel.mainFetchRequest())
        let workspaceModel = response?.first ?? createWorkspaceModel()
        return workspaceModel
    }

    private func createWorkspaceModel() -> WorkspaceModel {
        // swiftlint:disable force_cast
        return NSEntityDescription.insertNewObject(forEntityName: "Workspace", into: self) as! WorkspaceModel
    }
}
