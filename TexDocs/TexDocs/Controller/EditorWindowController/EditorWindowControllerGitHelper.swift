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
        showSheetStep(
            text: NSLocalizedString("TD_NOTIFICATION_CLONING_REPOSITORY", comment: "Message shown to the user while starting the cloning."),
            progressBarValue: .indeterminate
        )
        
        guard let localRepositoryURL = localRepositoryURL else {
            showErrorClosingSheet(
                text: NSLocalizedString("TD_ERROR_INTERNAL_ERROR", comment: "Message shown to the user if an internal error occures.")
            )
            return
        }
        
        repository = try GTRepository.clone(
            from: repositoryURL,
            toWorkingDirectory: localRepositoryURL,
            options: [
                GTRepositoryCloneOptionsPerformCheckout: true,
                GTRepositoryCloneOptionsCredentialProvider: credentialsProvider
        ]) { [weak self] (transferProgress, _) in
            let receivedObjects = transferProgress.pointee.received_objects
            let totalObjects = transferProgress.pointee.total_objects

            self?.showSheetStep(
                text: "\(NSLocalizedString("TD_NOTIFICATION_RECEIVING_OBJECTS", comment: "Shown while receiving objects from git remote.")) (\(receivedObjects)/\(totalObjects))",
                progressBarValue: .value(Double(receivedObjects)/Double(totalObjects))
            )
        }
        
        texDocsDocument?.documentData?.collaboration?.repository = DocumentData.Collaboration.Repository(url: repositoryURL)
        editedDocument()
        
        showUserNotificationSheet(text: NSLocalizedString("TD_NOTIFICATION_REPOSITORY_CLONED", comment: "Notification for the user after a successfull clone.")) {
            self.initiateSync()
        }
    }
    
    func initiateSync() {
        client.initiateSync()
        showSheetStep(text: "Requested Sync", progressBarValue: .indeterminate)
    }
    
    func completedUserSync() {
        self.client.completedUserSync()
        showSheetStep(text: "Waiting for sync to complete", progressBarValue: .indeterminate)
    }
}
