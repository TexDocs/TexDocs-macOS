//
//  EditorWindowController+CollaborationClientDelegate.swift
//  TexDocs
//
//  Created by Noah Peeters on 12.11.17.
//  Copyright © 2017 TexDocs. All rights reserved.
//

import Foundation

extension EditorWindowController: CollaborationClientDelegate {    
    func collaborationClient(_ client: CollaborationClient, didDisconnectedBecause reason: String) {
        showErrorSheet(withCustomMessage: reason)
    }
    
    func collaborationClient(_ client: CollaborationClient, encounteredError error: Error) {
        showErrorSheet(error)
    }
    
    func collaborationClient(_ client: CollaborationClient, didReceivedChangeIn range: NSRange, replacedWith replaceString: String) {
        DispatchQueue.main.async {
            self.editorViewController.editorView.replaceString(in: range, replacementString: replaceString)
            self.editedDocument()
        }
    }
    
    func collaborationCursorsChanged(_ client: CollaborationClient) {
        DispatchQueue.main.async {
            self.editorViewController.editorView.collaborationCursorsDidChange()
        }
    }
    
    func collaborationClient(_ client: CollaborationClient, didConnectedAndReceivedRepositoryURL repositoryURL: URL) {
        do {
            guard let oldRepositoryURL = texDocsDocument?.documentData?.collaboration?.repository?.url else {
                repository = try self.clone(repositoryURL: repositoryURL) {
                    self.scheduleSync()
                }
                return
            }
            
            guard oldRepositoryURL == repositoryURL else {
                showMissmatchedURLReceivedSheet()
                return
            }
            
            repository = try openLocalRepository()
            scheduleSync()
        } catch {
            showErrorSheet(error)
        }
    }
    
    func collaborationClientDidStartSync(_ client: CollaborationClient) {
        showSyncStartedSheet()
    }
    
    func collaborationClientDidStartUserSync(_ client: CollaborationClient) {
        do {
            showPullingStartedSheet()
            guard let repository = repository else {
                showInternalErrorSheet()
                return
            }

            let localMaster = try repository.currentBranch()

            guard let origin = try repository.configuration().remotes?[0],
                  let masterReferenceName = localMaster.reference.name else {
                    showInternalErrorSheet()
                    return
            }
            
            if !repository.isWorkingDirectoryClean {
                guard let head = try repository.headReference().resolvedTarget as? GTCommit else {
                    showInternalErrorSheet()
                    return
                }
                
                let index = try repository.index()
                index.addAll()
                
                try index.write()
                _ = try commit(repository, tree: index.writeTree(), parents: [head], message: "Client Update", updatingReferenceNamed: masterReferenceName)
            }
            
            do {
                try pull(repository, branch: localMaster, from: origin)
            } catch let error as NSError where error.code == GIT_ECONFLICT.rawValue {
                
                let index = try repository.index()
                
                if index.hasConflicts {
                    git_index_conflict_cleanup(index.git_index())
                    index.addAll()
                    try index.write()
                }
                
                let mergeHeadError: NSErrorPointer = nil
                let remoteMergeHeads = try repository.mergeHeadEntriesWithError(mergeHeadError).map {
                    try repository.lookUpObject(by: $0) as! GTCommit
                }
                let mergeHeads = try [[repository.currentBranch().targetCommit()], remoteMergeHeads].flatMap { $0 }
                let message = try repository.preparedMessage()
                
                _ = try commit(repository, tree: repository.index().writeTree(), parents: mergeHeads, message: message, updatingReferenceNamed: masterReferenceName)
                
                git_repository_state_cleanup(repository.git_repository())
            } catch {
                throw error
            }
            try push(repository, branch: localMaster, to: origin)
            
            completedUserSync()
        } catch {
            showErrorSheet(error)
        }
    }
    
    func collaborationClientDidCompletedSync(_ client: CollaborationClient) {
        do {
            showPullingStartedSheet()
            guard let repository = repository else {
                showInternalErrorSheet()
                return
            }
            let master = try repository.currentBranch()
            
            guard let origin = try repository.configuration().remotes?[0] else {
                    showInternalErrorSheet()
                    return
            }
            
            try pull(repository, branch: master, from: origin)
            
            showSyncCompletedSheet()
            client.completedSync()
        } catch {
            showErrorSheet(error)
        }
    }
}

extension GTIndex {
    func addAll() {
        git_index_add_all(git_index(), nil, GIT_INDEX_ADD_CHECK_PATHSPEC.rawValue, nil, nil)
    }
}
