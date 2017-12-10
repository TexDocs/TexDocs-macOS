//
//  EditorWindowController+CollaborationClientDelegate.swift
//  TexDocs
//
//  Created by Noah Peeters on 12.11.17.
//  Copyright © 2017 TexDocs. All rights reserved.
//

import Foundation

extension EditorWindowController {
    func connectTo(collaborationServer: DocumentData.Collaboration.Server) {
        showConnectingSheet()
        client.connect(to: collaborationServer.url)
    }

    func receivedChange(in range: NSRange, replaceWith replaceString: String, inFile relativeFilePath: String) {
        if relativePathOfOpenedFile() == relativeFilePath {
            DispatchQueue.main.async {
                self.editorViewController.openedEditor?.receivedChange(in: range, replaceWith: replaceString)
            }
        } else {
            guard let fileSystemItem = rootDirectory?.findChild(withRelativePath: relativeFilePath, includesRootItemsName: true) as? EditableFileSystemItem else {
                return
            }
            fileSystemItem.string.replaceString(in: range, replacementString: replaceString)
            editedDocument()
        }
    }
}

extension EditorWindowController: CollaborationClientDelegate {
    func collaborationClient(_ client: CollaborationClient, didDisconnectedBecause reason: String) {
        showErrorSheet(withCustomMessage: reason)
    }

    func collaborationClient(_ client: CollaborationClient, encounteredError error: Error) {
        showErrorSheet(error)
    }

    func collaborationClient(_ client: CollaborationClient, didReceivedChangeIn range: NSRange, replacedWith replaceString: String, inFile relativeFilePath: String) {
        receivedChange(in: range, replaceWith: replaceString, inFile: relativeFilePath)
    }

    func collaborationCursorsChanged(_ client: CollaborationClient) {
        DispatchQueue.main.async {
            self.editorViewController.openedEditor?.collaborationCursorsDidChange()
        }
    }

    func collaborationClient(_ client: CollaborationClient, didConnectedAndReceivedRepositoryURL repositoryURL: URL) {
        do {
            guard let oldRepositoryURL = texDocsDocument.documentData?.collaboration?.repository?.url else {
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
            saveAllDocuments()
            
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
                    
                    try index.enumerateConflictedFiles { (ancestor, ours, theirs, _) in
                        
                        let result: UnsafeMutablePointer<git_merge_file_result>! = nil

                        git_merge_file_from_index(result, repository.git_repository(), ancestor.git_index_entry(), ours.git_index_entry(), theirs.git_index_entry(), nil)
                        
                        let content = String(cString: result.pointee.ptr)
                        let path = String(cString: result.pointee.path)
                        
                        try! content.write(to: URL(fileURLWithPath: path), atomically: false, encoding: .utf8)
                        git_index_conflict_remove(index.git_index(), result.pointee.path)
                        try! index.addFile(path)
                        
                        git_merge_file_result_free(result)
                    }
                    
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
            reloadAllDocuments()
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

extension String {
    mutating func replaceString(in range: NSRange, replacementString: String) {
        let stringRange = Range(range, in: self)!
        self.replaceSubrange(stringRange, with: replacementString)
    }
}
