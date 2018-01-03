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

    var collaborationDelegate: VersionedFileCollaborationDelegate?

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
            commit.index = commit.index + 1
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

extension NSManagedObjectContext {
    func fetchOrCreateWorkspaceModel(collaborationDelegate: VersionedFileCollaborationDelegate) -> WorkspaceModel {
        let response = try? fetch(WorkspaceModel.mainFetchRequest())
        let workspaceModel = response?.first ?? createWorkspaceModel()
        workspaceModel.collaborationDelegate = collaborationDelegate
        return workspaceModel
    }

    private func createWorkspaceModel() -> WorkspaceModel {
        return NSEntityDescription.insertNewObject(forEntityName: "Workspace", into: self) as! WorkspaceModel
    }
}
