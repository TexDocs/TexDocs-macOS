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
    }
    
    func collaborationCursorsChanged(_ client: CollaborationClient) {
        editorViewController.editorView.collaborationCursorsDidChange()
    }
    
    func collaborationClient(_ client: CollaborationClient, didConnectedAndReceivedRepoURL repoURL: URL) {
        guard let oldRepoURL = self.texDocsDocument?.documentData?.collaboration?.repo?.url else {
            //TODO: clone repo
            print("clone")
            closeSheet()
            return
        }
        
        guard oldRepoURL == repoURL else {
            showErrorClosingSheet(text: "Missmatching repo url received from server.")
            return
        }
        
        print("start sync")
        closeSheet()
    }
}
