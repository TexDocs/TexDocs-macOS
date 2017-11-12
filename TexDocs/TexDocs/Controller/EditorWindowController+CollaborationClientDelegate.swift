//
//  EditorWindowController+CollaborationClientDelegate.swift
//  TexDocs
//
//  Created by Noah Peeters on 12.11.17.
//  Copyright © 2017 TexDocs. All rights reserved.
//

import Foundation

extension EditorWindowController: CollaborationClientDelegate {
    func collaborationCursorsChanged(in client: CollaborationClient) {
        editorViewController.editorView.collaborationCursorsDidChange()
    }
}
