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
    
    func collaborationClient(_ client: CollaborationClient, didConnectedAndReceivedRepositoryURL repositoryURL: URL) {
        guard let oldRepositoryURL = texDocsDocument?.documentData?.collaboration?.repository?.url else {
            showSheetStep(text: "Cloning repository...", progressBarValue: .indeterminate)
            DispatchQueue.global(qos: .userInitiated).async { [weak self] in
                do {
                    try self?.clone(repositoryURL: repositoryURL)
                } catch {
                    self?.showErrorClosingSheet(text: error.localizedDescription)
                }
            }
            return
        }
        
        guard oldRepositoryURL == repositoryURL else {
            showErrorClosingSheet(text: "Missmatching repository url received from server.")
            return
        }
        
        print("start sync")
        closeSheet()
    }
}
