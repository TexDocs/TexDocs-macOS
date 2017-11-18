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
        showErrorClosingSheet(text: reason)
    }
    
    func collaborationClient(_ client: CollaborationClient, encounteredError error: Error) {
        showErrorClosingSheet(text: error.localizedDescription)
    }
    
    func collaborationClient(_ client: CollaborationClient, didReceivedChangeIn range: NSRange, replacedWith replaceString: String) {
        editorViewController.editorView.replaceString(in: range, replacementString: replaceString)
        editedDocument()
    }
    
    func collaborationCursorsChanged(_ client: CollaborationClient) {
        editorViewController.editorView.collaborationCursorsDidChange()
    }
    
    func collaborationClient(_ client: CollaborationClient, didConnectedAndReceivedRepositoryURL repositoryURL: URL) {
        guard let oldRepositoryURL = texDocsDocument?.documentData?.collaboration?.repository?.url else {
            do {
                try self.clone(repositoryURL: repositoryURL)
            } catch {
                self.showErrorClosingSheet(text: error.localizedDescription)
            }
            return
        }
        
        guard oldRepositoryURL == repositoryURL else {
            showErrorClosingSheet(
                text: NSLocalizedString("TD_ERROR_MISSMATCHED_REPOSITORY_URL", comment: "Message shown to the user if the saved and the received repository url don't match.")
            )
            return
        }
        
        initiateSync()
    }
    
    func collaborationClientDidStartSync(_ client: CollaborationClient) {
        showSheetStep(text: "Waiting for sync", progressBarValue: .indeterminate)
    }
    
    func collaborationClientDidStartUserSync(_ client: CollaborationClient) {
        showSheetStep(text: "Syncing...", progressBarValue: .value(0.5))
        //TODO commit pull push
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            self.completedUserSync()
        }
    }
    
    func collaborationClientDidCompletedSync(_ client: CollaborationClient) {
        showUserNotificationSheet(text: "Completed sync.")
    }
}
