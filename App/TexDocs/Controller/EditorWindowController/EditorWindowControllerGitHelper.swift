//
//  EditorWindowControllerGitHelper.swift
//  TexDocs
//
//  Created by Noah Peeters on 17.11.17.
//  Copyright © 2017 TexDocs. All rights reserved.
//

import Foundation

extension EditorWindowController {
    private var credentialsProvider: GTCredentialProvider {
        return GTCredentialProvider() { (type, url, userName) in
            return try? GTCredential(
                userName: userName,
                publicKeyURL: URL(fileURLWithPath: NSString(string: UserDefaults.publicKeyPath.value).expandingTildeInPath),
                privateKeyURL: URL(fileURLWithPath: NSString(string: UserDefaults.privateKeyPath.value).expandingTildeInPath),
                passphrase: nil)
        }
    }

    private var signature: GTSignature? {
        return GTSignature(
            name: UserDefaults.gitName.value,
            email: UserDefaults.gitEMail.value,
            time: Date())
    }

    func clone(repositoryURL: URL, action: (() -> Void)? = nil) throws -> GTRepository? {
        guard let localRepositoryURL = dataFolderURL else {
            showInternalErrorSheet()
            return nil
        }
        showCloningSheet()

        client.willStartCloning()
        let repository = try GTRepository.clone(
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

        texDocsDocument.documentData?.collaboration?.repository = DocumentData.Collaboration.Repository(url: repositoryURL)
        editedDocument()
        DispatchQueue.main.async {
            self.srcDirectoryDidChange()
        }
        showCloningCompletedSheet(action: action)
        return repository
    }

    func openLocalRepository() throws -> GTRepository? {
        guard let localRepositoryURL = dataFolderURL else {
            showInternalErrorSheet()
            return nil
        }

        let repository = try GTRepository(url: localRepositoryURL)

        return repository
    }

    func pull(_ repository: GTRepository, branch: GTBranch, from remote: GTRemote) throws {
        try repository.pull(
            branch,
            from: remote,
            withOptions: [
                GTRepositoryRemoteOptionsCredentialProvider: credentialsProvider,
                GTPullMergeConflictedFiles: true
        ]) { [weak self] (transferProgress, _) in
            let receivedObjects = transferProgress.pointee.received_objects
            let totalObjects = transferProgress.pointee.total_objects
            self?.showPullingProgressSheet(total: totalObjects, completed: receivedObjects)
        }
    }

    func fetch(_ repository: GTRepository, from remote: GTRemote) throws {
        try repository.fetch(
            remote, withOptions: [
                GTRepositoryRemoteOptionsCredentialProvider: credentialsProvider
        ]) { [weak self] (transferProgress, _) in
            let receivedObjects = transferProgress.pointee.received_objects
            let totalObjects = transferProgress.pointee.total_objects
            self?.showFetchProgressSheet(total: totalObjects, completed: receivedObjects)
        }
    }

    func push(_ repository: GTRepository, branch: GTBranch, to remote: GTRemote) throws {
        try repository.push(
            branch,
            to: remote,
            withOptions: [
                GTRepositoryRemoteOptionsCredentialProvider: credentialsProvider
        ]) { [weak self] (pushed, total, _, _) in
            self?.showPushingProgressSheet(total: total, completed: pushed)
        }
    }

    func commit(_ repository: GTRepository, tree: GTTree, parents: [GTCommit], message: String, updatingReferenceNamed referenceName: String) throws ->
        GTCommit {
            guard let signature = signature else {
                throw EditorWindowControllerError.invalidSignature
            }

            return try repository.createCommit(
                with: tree,
                message: message,
                author: signature,
                committer: signature,
                parents: parents,
                updatingReferenceNamed: referenceName
            )
    }

    func scheduleSync() {
        self.client.scheduleSync()
        showScheduledSyncSheet()
    }

    func completedUserSync() {
        showCompletedUserSyncSheet()
        client.completedUserSync()
    }
}

enum EditorWindowControllerError: Error {
    case invalidSignature

    var localizedDescription: String {
        switch self {
        case .invalidSignature:
            return NSLocalizedString("TD_INVALID_SIGNATURE", comment: "Error description if the signature is invalid.")
        }
    }
}

extension GTRepositoryStashApplyProgress {
    static let totalSteps = 7
}

