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
            showMissmatchedURLReceivedSheet()
            return
        }
        
        scheduleSync()
    }
    
    func collaborationClientDidStartSync(_ client: CollaborationClient) {
        showSyncStartedSheet()
    }
    
    func collaborationClientDidStartUserSync(_ client: CollaborationClient) {
        showCloningProgressSheet(total: 2, completed: 1)
        //TODO commit pull push
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            self.completedUserSync()
        }
    }
    
    func collaborationClientDidCompletedSync(_ client: CollaborationClient) {
        showSyncCompletedSheet()
    }
}
