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
        guard let repositoryLocalURL = repositoryLocalURL else {
            showErrorClosingSheet(text: "Workspace not found!")
            return
        }
        
        repository = try GTRepository.clone(
            from: repositoryURL,
            toWorkingDirectory: repositoryLocalURL,
            options: [
                GTRepositoryCloneOptionsPerformCheckout: true,
                GTRepositoryCloneOptionsCredentialProvider: credentialsProvider
        ]) { [weak self] (transferProgress, _) in
            let receivedObjects = transferProgress.pointee.received_objects
            let totalObjects = transferProgress.pointee.total_objects

            self?.showSheetStep(
                text: "Receiving objects (\(receivedObjects)/\(totalObjects))",
                progressBarValue: .value(Double(receivedObjects)/Double(totalObjects))
            )
        }
        
        texDocsDocument?.documentData?.collaboration?.repository = DocumentData.Collaboration.Repository(url: repositoryURL)
        
        showUserNotificationSheet(text: "Cloned Repository") {
            print("sync")
        }
    }
}
