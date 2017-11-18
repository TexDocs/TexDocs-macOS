//
//  EditorWindowControllerGitHelper.swift
//  TexDocs
//
//  Created by Noah Peeters on 17.11.17.
//  Copyright © 2017 TexDocs. All rights reserved.
//

import Foundation

extension EditorWindowController {
    var credentialsProvider: GTCredentialProvider {
        return GTCredentialProvider() { (type, url, userName) in
            return try? GTCredential(
                userName: userName,
                publicKeyURL: URL(fileURLWithPath: "/Users/noahpeeters/.ssh/id_rsa.pub"),
                privateKeyURL: URL(fileURLWithPath: "/Users/noahpeeters/.ssh/id_rsa"),
                passphrase: nil)
        }
    }
    
    func clone(repositoryURL: URL) throws {
        guard let localRepositoryURL = localRepositoryURL else {
            showInternalErrorSheet()
            return
        }
        showCloningSheet()
        
        repository = try GTRepository.clone(
            from: repositoryURL,
            toWorkingDirectory: localRepositoryURL,
            options: [
                GTRepositoryCloneOptionsPerformCheckout: true,
                GTRepositoryCloneOptionsCredentialProvider: credentialsProvider
        ]) { [weak self] (transferProgress, _) in
            let receivedObjects = transferProgress.pointee.received_objects
            let totalObjects = transferProgress.pointee.total_objects

            self?.showCloningProgressSheet(total: totalObjects, completed: receivedObjects)
        }
        
        texDocsDocument?.documentData?.collaboration?.repository = DocumentData.Collaboration.Repository(url: repositoryURL)
        editedDocument()
        showCloningCompletedSheet() {
            self.scheduleSync()
        }
        
    }
    
    func scheduleSync() {
        client.scheduleSync()
        showScheduledSyncSheet()
    }
    
    func completedUserSync() {
        client.completedUserSync()
        showCompletedUserSyncSheet()
    }
}
